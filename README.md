# pub.scripts.misc
Misc scripts for public consumption.  Public scripts for making life / maintenance in Linux easier.


### launchSpider:
A script for launching the lantronix spider ipkvm w/o having to log-in to the web UI.  

Flow:
* Authenticate to web UI (HTTP POST) and save session cookie.
* Get security token from active sesssion.
* Download .jnlp using current security token.
* Execute .jnlp
