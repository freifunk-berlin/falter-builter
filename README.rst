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

    pip3 install selenium

Um funktionieren zu können, benötigt selenium einen webdriver, der Browser-
abhängig ist. Dieser muss mit PATH erreichbar sein (ergo webdriver z.B. unter
**/usr/bin** ablegen). Weitere Infos dazu gibt es im `selenium-Handbuch <https://selenium-python.readthedocs.io/installation.html#drivers>`_

Firefox-treiber:
    https://github.com/mozilla/geckodriver/releases

Chrome-treiber:
    https://sites.google.com/a/chromium.org/chromedriver/downloads
    
Benutzung
^^^^^^^^^
