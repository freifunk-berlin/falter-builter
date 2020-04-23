#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from time import sleep
import json
import sys


## config ##
luci_webadress = "http://frei.funk"
luci_timeout_long = 6
luci_timeout = 2

configs = {}

filepath = sys.argv[1]
with open(filepath) as f:
    configs = json.loads(f.read())


def click_next(browser):
    button = browser.find_element_by_class_name("cbi-button.cbi-button-save")
    button.click()


browser = webdriver.Firefox()
browser.implicitly_wait(1)

# call LuCI-interface and wait unti its loaded
browser.get(luci_webadress)
sleep(luci_timeout_long)
# figure out success via checking pagetitle fo "LuCI"
try:
    assert "LuCI" in browser.title, "connecting to "+luci_webadress+" failed!"
except:
    print("connecting to " + luci_webadress + " failed!")
    print("exiting...")
    exit(1)


# set password
pw_0 = browser.find_element_by_name("cbid.ffwizward.1.pw1")
pw_1 = browser.find_element_by_name("cbid.ffwizward.1.pw2")

pw_0.send_keys(configs.get("passwd"))
pw_1.send_keys(configs.get("passwd"))
# browser.save_screenshot('screenshot.png')
click_next(browser)

sleep(2)
# put data into fields
hostname = browser.find_element_by_name("cbid.ffwizward.1.hostname")
nickname = browser.find_element_by_name("cbid.ffwizward.1.nickname")
realname = browser.find_element_by_name("cbid.ffwizward.1.realname")
email = browser.find_element_by_name("cbid.ffwizward.1.mail")
location = browser.find_element_by_name("cbid.ffwizward.1.location")
lat = browser.find_element_by_name("cbid.ffwizward.1.lat")
lon = browser.find_element_by_name("cbid.ffwizward.1.lon")

hostname.clear()
hostname.send_keys(configs.get("hostname"))
nickname.send_keys(configs.get("nickname"))
realname.send_keys(configs.get("realname"))
email.send_keys(configs.get("email"))
location.send_keys(configs.get("location"))
lat.send_keys(configs.get("lat"))
lon.send_keys(configs.get("lon"))

click_next(browser)

# decide on dsl yes/no
if configs.get("sharenet") == False:  # sys.argv[1] == "-m":
    # click "Am Freifunknetz teilnehmen"
    browser.find_element_by_link_text("Am Freifunk-Netz teilnehmen").click()

else:
    # click "Am Freifunknetz teilnehmen und Internet teilen"
    elem = browser.find_element_by_link_text(
        "Am Freifunk-Netz teilnehmen und Internet teilen").click()

    # configure bandwidth of sharenet
    bw_down = browser.find_element_by_name(
        "cbid.ffuplink.1.usersBandwidthDown")
    bw_up = browser.find_element_by_name(
        "cbid.ffuplink.1.usersBandwidthUp")

    bw_down.send_keys(configs.get("bandwidth_down"))
    bw_up.send_keys(configs.get("bandwidth_up"))

    click_next(browser)

# monitoring yes/no
if configs.get("monitoring") == True:
    elem = browser.find_element_by_name("cbid.ffwizard.1.stats")
    elem.click()

click_next(browser)

# set ip-adresses
sleep(2)
radio0 = browser.find_element_by_name("cbid.ffwizard.1.meship_radio0")
dhcp = browser.find_element_by_name("cbid.ffwizard.1.dhcpmesh")

radio0.send_keys(configs.get("ip_radio0"))
# radio1 is not present on all routers
try:
    radio1 = browser.find_element_by_name("cbid.ffwizard.1.meship_radio1")
    radio1.send_keys(configs.get("ip_radio1"))
except:
    print("There was no radio1 in LuCI-Wizard. Therefore radio1-IP-Adress not set.")

dhcp.send_keys(configs.get("ip_dhcp"))

click_next(browser)


sleep(2)
print("Configuration of your test-node seems to be successfully done.")

browser.close()

exit()
