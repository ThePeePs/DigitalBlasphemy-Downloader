## DB-RSS-Reader
This perl script will read the RSS feed from http://digitalblasphemy.com and auto download user selected sizes of Ryan's latest renders.
You need to be a Member of the site to download the Hi-Res versions (member-sizes).


## Installation
# Windows Install

Download Perl for Windows from http://strawberryperl.com and install.

Open a cmd prompt and install the required perl modules. (copy/paste below)

    cpan Sys::Hostname::Long Config::IniHash DateTime::Format::Mail HTML::TreeBuilder::XPath Mail::Sender XML::RSS::Parser

Download Git client for windows at: http://windows.github.com and install

Open the "Git Shell" and paste the following:
    git clone https://github.com/ThePeePs/DigitalBlasphemy-Downloader.git db-downloader

Copy or rename db-rss-reader.ini.default to db-rss-reader.ini.
Edit the config (db-rss-reader.ini) to suit your needs. (I suggest using Wordpad or [Notepad++](http://notepad-plus-plus-.org/download/v6.5.3.html "Notepad++ Website"))

Then run the script.
    perl db-rss-reader.pl

I suggest you set it up as a scheduled task to run at least once a week.




# Linux Install (Debian/Ubuntu)

    sudo apt-get install git libconfig-inihash-perl libwww-perl libhtml-treebuilder-xpath-perl libmail-sender-perl 
    sudo cpan DateTime::Format::Mail XML::RSS::Parser

Clone the repo.
    git clone https://github.com/ThPeePs/DigitalBlasphemy-Downloader.git

Copy or rename db-rss-reader.ini.default to db-rss-reader.ini.
Edit the config (db-rss-reader.ini) to suit your needs.

Then run the script.
    perl db-rss-reader.pl

I suggest you set it up as a cron job to run at least once a week.


If you have any suggestions or find a bug, please open a issue.
If you feel that you can contribute, please fork the repo, and submit a Pull Request.


Donations welcome:

LTC - LeY83s2QE83MruyNsJjfcsJYiKF9fRxhNM
CAT - 9rNerHqUTcoLPGtiUxiR3L6onAxe1MRBst
TAG - TBgDDevQrgnP9adAeWyLTYJkw4YhDzsNPS
