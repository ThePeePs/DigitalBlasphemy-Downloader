# DB-RSS-Reader
This perl script will read the RSS feed from http://digitalblasphemy.com and auto download user selected sizes of Ryan's latest renders.
You need to be a Member of the site to download the Hi-Res versions (member-sizes).<br>
If you have any suggestions, feature requests or find a bug, please open a issue.<br>
If you would like to contribute, please fork the repo, and submit a Pull Request.

## Usage
If you are on Windows, you need to install Perl (see Windows Install). The following modules are also requred.<br>
* Sys::Hostname::Long
* Config::IniHash
* LWP
* LWP::Authen::Basic
* HTML::TreeBuilder::XPath
* HTML::Parser
* XML::RSS::Parser
* DateTime::Format:Mail
* Mail::Sender

The script needs to be run  from it's directory, or it will not be able to find the config file.

patcher.pl should be used after you updated (either git pull or svn checkout).  It will add any new sizes that Ryan has added to the site (commented out), and remove the ones that are longer offered.  It should also be run from it's directory. 

## Installation
### Windows Install

Download Perl for Windows from http://strawberryperl.com and install.

Open a cmd prompt and install the required perl modules. (copy/paste below)<br>
    cpan Sys::Hostname::Long Config::IniHash DateTime::Format::Mail HTML::TreeBuilder::XPath Mail::Sender XML::RSS::Parser

Download Git client for windows at: http://windows.github.com and install

Open the "Git Shell" and paste the following:<br>
    git clone https://github.com/ThePeePs/DigitalBlasphemy-Downloader.git db-downloader


If you do not feel confertabla with using Git, you can also use [TortoiseSVN](http://tortoisesvn.net/downloads.html "TortoiseSVN Download link")

Create a new folder, right-click on it, select SVN Checkout.. and paste the following in to URL feed:<br>
    https://github.com/ThePeePs/DigitalBlasphemy-Downloader


Copy or rename db-rss-reader.ini.default to db-rss-reader.ini.<br>
Edit the config (db-rss-reader.ini) to suit your needs. (I suggest using Wordpad or [Notepad++](http://notepad-plus-plus-.org/download/v6.5.3.html "Notepad++ Website"))

To run the scipt. open a command prompt, and cd to the directory of the script, and enter:<br>
    perl db-rss-reader.pl

I suggest you set it up as a scheduled task to run at least once a week.




### Linux Install (Debian/Ubuntu)

    sudo apt-get install git libconfig-inihash-perl libwww-perl libhtml-treebuilder-xpath-perl libmail-sender-perl 
    sudo cpan DateTime::Format::Mail XML::RSS::Parser

Clone the repo.<br>
    git clone https://github.com/ThPeePs/DigitalBlasphemy-Downloader.git

Copy or rename db-rss-reader.ini.default to db-rss-reader.ini.<br>
Edit the config (db-rss-reader.ini) to suit your needs.

Then run the script from it's directory.<br>
    perl db-rss-reader.pl

I suggest you set it up as a cron job to run at least once a week.



##### Donations welcome:

LTC - LeY83s2QE83MruyNsJjfcsJYiKF9fRxhNM<br>
CAT - 9rNerHqUTcoLPGtiUxiR3L6onAxe1MRBst<br>
TAG - TBgDDevQrgnP9adAeWyLTYJkw4YhDzsNPS<br>
