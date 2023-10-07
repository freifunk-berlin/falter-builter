#!/usr/bin/env python3

# mypy: disable-error-code="attr-defined"

import argparse
import json
from argparse import RawTextHelpFormatter
from time import sleep

from pyvirtualdisplay import Display
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.ui import Select

luci_webaddress = "http://192.168.42.1"
luci_timeout_long = 12
luci_timeout = 2

# standard values. They apply, if no other values (via config file or cmd-option) were provided
configs = {
    "location": "somewhere in (maybe) Berlin",
    "lat": "52.4875104819595",
    "lon": "13.214267492294312",
    "sharenet_off": False,
    "download": "25",
    "upload": "12",
    "monitoring_off": False,
}


##############################
#    Argument-paser stuff    #
##############################

parser = argparse.ArgumentParser(
    description="""A tool for testing Freifunk-Berlin-Wizard fast and easy.
It's also very useful, if you want to configure nodes seamlessly quick.
If you give a value via cmdl-options, they will overide those values from the configuration-file.

If you are in a hurry, you may only provide this information to the script:
* password
* hostname
* your contact (email or web-form)
* IP for DHCP
* IP for meshing on radio0

For the rest, the script will insert some standart-values. Have a look in the code.""",
    formatter_class=RawTextHelpFormatter,
)
parser.add_argument(
    "path", nargs="?", help="path to configuration file in json-format (optional)"
)
parser.add_argument("-p", "--passwd", type=str, help="Passwort for user root.")
parser.add_argument(
    "-n",
    "--hostname",
    type=str,
    help="hostname of your new freifunk router. Please have a look at RFC1178.",
)
parser.add_argument("--nickname", type=str, help="your nickname")
parser.add_argument("--realname", type=str, help="your real name")
parser.add_argument(
    "-c",
    "--contact",
    type=str,
    help="""contact data of the operator. Give an e-mail-address or the link for
your personal e-mail-form from config.berlin.freifunk.net""",
)
parser.add_argument(
    "--community", type=str, help="select another community-profile than standard"
)
parser.add_argument(
    "-l", "--location", type=str, help="description of routers location (e.g. address)"
)
parser.add_argument(
    "-x", "--lat", type=str, help="latitude of routers position (decimal)"
)
parser.add_argument(
    "-y", "--lon", type=str, help="longintude of routers postition (decimal)"
)
parser.add_argument(
    "--sharenet-off",
    action="store_true",
    help="deactivate sharing off your own internet to others",
)
parser.add_argument("--upload", type=str, help="bandwidth-limit for sharing your net")
parser.add_argument("--download", type=str, help="bandwidth-limit for sharing your net")
parser.add_argument(
    "--monitoring-off",
    action="store_true",
    help="deactivate sending statistics to monitor.berlin.freifunk.net",
)
parser.add_argument(
    "--adhoc", action="store_true", help="use deprecated ad-hoc as mesh-technology"
)
parser.add_argument(
    "-d", "--dhcp", type=str, help="ip-address of DHCP-Network from the mail."
)
parser.add_argument("-r", "--radio0", type=str, help="mesh-ip-address for radio0")
parser.add_argument("-s", "--radio1", type=str, help="mesh-ip-address for radio1")
args = parser.parse_args()


# read configs from file (if any). If value is not defined in config, preserve standard value.
if args.path:
    conf = {}
    with open(args.path) as f:
        conf = json.loads(f.read())
    for option in conf.keys():
        configs[option] = conf.get(option)

# read commandline arguments into config
opt = vars(args)
for option in opt:
    if option == "path":
        continue
    else:
        if opt.get(option):
            configs[option] = opt.get(option)

# check, if all mandatory values were given
mandatory = ["passwd", "hostname", "radio0", "dhcp"]
for param in mandatory:
    if not opt.get(param) and not configs.get(param):
        print(
            "Didn't get enough information for configuring your freifunk-node.\n \
            I need at least:\n\t* passwd\n\t* hostname\n\t* mesh-ip-radio0\n\t* ip-dhcp\n\n \
            The rest, I'll fill with standard-values."
        )
        exit(1)


##############################
#    Play around with LuCI   #
##############################


def click_next(browser):
    button = browser.find_element(by=By.CLASS_NAME, value="cbi-button.cbi-button-save")
    button.click()


display = Display(visible=0, size=(1280, 720))
display.start()

profile = FirefoxProfile()
profile.set_preference("intl.accept_languages", "de-DE")
opt = Options()
opt.profile = profile

browser = webdriver.Firefox(options=opt)
browser.implicitly_wait(1)

# call LuCI-interface and wait unti its loaded
browser.get(luci_webaddress)

# figure out success via checking pagetitle fo "LuCI"
error_count = 0
while "LuCI" not in browser.title:
    sleep(2)
    error_count += 1
    if error_count > 12:
        print("connecting to " + luci_webaddress + " failed!")
        print("exiting...")
        exit(1)

# password field appears slightly late
pw_0 = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.pw1")
pw_1 = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.pw2")
while not pw_0:
    try:
        sleep(luci_timeout)
        pw_0 = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.pw1")
        pw_1 = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.pw2")
    except Exception:
        continue


pw_0.send_keys(configs.get("passwd"))
pw_1.send_keys(configs.get("passwd"))
browser.save_screenshot("01_password.png")
click_next(browser)

sleep(2)

# select community
if args.community or configs.get("community"):
    community = args.community or configs.get("community")
    dropdown = Select(
        browser.find_element(by=By.ID, value="widget.cbid.ffwizward.1.net")
    )
    dropdown.select_by_value(community)

# put data into fields
hostname = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.hostname")
nickname = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.nickname")
realname = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.realname")
contact = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.mail")
location = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.location")
lat = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.lat")
lon = browser.find_element(by=By.NAME, value="cbid.ffwizward.1.lon")

hostname.clear()
hostname.send_keys(configs.get("hostname"))
if configs.get("nickname"):
    nickname.send_keys(configs.get("nickname"))
if configs.get("realname"):
    realname.send_keys(configs.get("realname"))
if configs.get("contact"):
    contact.send_keys(configs.get("contact"))
if configs.get("location"):
    location.send_keys(configs.get("location"))
if configs.get("lat"):
    lat.send_keys(configs.get("lat"))
if configs.get("lon"):
    lon.send_keys(configs.get("lon"))

browser.save_screenshot("02_general_settings.png")
click_next(browser)

# decide on dsl yes/no
browser.save_screenshot("03_share_inet.png")
if configs.get("sharenet_off"):
    # click "Am Freifunknetz teilnehmen"
    try:
        browser.find_element(
            by=By.LINK_TEXT, value="Am Freifunk-Netz teilnehmen"
        ).click()
    except Exception:
        browser.find_element(
            by=By.LINK_TEXT, value="Participate in the Freifunk-Network"
        ).click()


else:
    # click "Am Freifunknetz teilnehmen und Internet teilen"
    try:
        elem = browser.find_element(
            by=By.LINK_TEXT, value="Am Freifunk-Netz teilnehmen und Internet teilen"
        ).click()
    except Exception:
        elem = browser.find_element(
            by=By.LINK_TEXT,
            value="Participate in the Freifunk-Network and share Internet",
        ).click()

    # configure bandwidth of sharenet
    bw_down = browser.find_element(
        by=By.NAME, value="cbid.ffuplink.1.usersBandwidthDown"
    )
    bw_up = browser.find_element(by=By.NAME, value="cbid.ffuplink.1.usersBandwidthUp")

    bw_down.send_keys(configs.get("download"))
    bw_up.send_keys(configs.get("upload"))

    browser.save_screenshot("03a_share_bandwidth.png")
    click_next(browser)

# monitoring yes/no
if not configs.get("monitoring_off"):
    elem = browser.find_element(by=By.NAME, value="cbid.ffwizard.1.stats")
    elem.click()

browser.save_screenshot("04_monitoring.png")
click_next(browser)

# set ip-adresses
sleep(2)
radio0 = browser.find_element(by=By.NAME, value="cbid.ffwizard.1.meship_radio0")
dhcp = browser.find_element(by=By.NAME, value="cbid.ffwizard.1.dhcpmesh")

radio0.send_keys(configs.get("radio0"))
# radio1 is not present on all routers
try:
    radio1 = browser.find_element(by=By.NAME, value="cbid.ffwizard.1.meship_radio1")
    radio1.send_keys(configs.get("radio1"))
except Exception:
    print("There was no radio1 in LuCI-Wizard. Therefore radio1-IP-Adress not set.")

dhcp.send_keys(configs.get("dhcp"))

# configure mesh mode ad-hoc
if args.adhoc:
    browser.find_element_by_id("cbid.ffwizard.1.mode_radio0-adhoc").click

browser.save_screenshot("05_ipaddr.png")
click_next(browser)


sleep(2)
print("Configuration of your test-node seems to be successfully done.")

browser.save_screenshot("06_finished.png")
browser.close()

browser.quit()
display.stop()

exit()
