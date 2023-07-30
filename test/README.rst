wizard-tester
=============

``wizard-tester`` ist ein python-skript, dass das Testen von Firmwarebuilds
von Freifunk Berlin vereinfacht. Es liest die Daten eines Routers aus einer
``json``-datei aus und trägt diese automatisch in den Wizard ein. Dadurch
kann die Konfiguration eines Knotens zu Testzwecken fast komplett autonom
erfolgen.

Abhängikeiten
^^^^^^^^^^^^^

Es wird das python-modul ``selenium`` benötigt. Falls noch nicht vorhanden,
kann es über pip nachinstalliert werden.
::

    pip3 install selenium

Um funktionieren zu können, benötigt selenium einen webdriver, der Browser-
abhängig ist. Dieser muss mit PATH erreichbar sein (ergo webdriver z.B. unter
**/usr/bin** ablegen). Weitere Infos dazu gibt es im `selenium-Handbuch <https://selenium-python.readthedocs.io/installation.html#drivers>`_

Firefox-treiber:
::
    https://github.com/mozilla/geckodriver/releases

Chrome-treiber:
::
    https://sites.google.com/a/chromium.org/chromedriver/downloads
    
Benutzung
^^^^^^^^^

``wizard-tester`` nimmt die Daten, um einen knoten zu konfigurieren aus einer
``json``-datei, die beim start als Paramter mit übergeben wird:
::
    ./wizard-tester.py node_config.json


Format node_config.json
^^^^^^^^^^^^^^^^^^^^^^^
Beispieldatei mit allen Werten:
::
    {
        "passwd": "123456",
        "hostname": "testnode",
        "nickname": "Nick Name",
        "realname": "Mr. Real Name",
        "contact": "some@emailaddress.com",
        "location": "somewhere on planet Earth",
        "lat": "52.4875104819595",
        "lon": "13.214267492294312",
        "sharenet_off": false,
        "download": "8",
        "upload": "3",
        "monitoring_off": false,
        "radio0": "172.16.6.2",
        "radio1": "172.16.6.3",
        "dhcp": "172.16.5.1/27"
    }
