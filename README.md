# DB-RSS-Reader
This perl script will read the RSS feed from http://digitalblasphemy.com and auto download user selected sizes of Ryan's latest renders.
You need to be a Member of the site to download the Hi-Res versions (member-sizes).<br>
If you have any suggestions, feature requests or find a bug, please open a issue.<br>
If you would like to contribute, please fork the repo, and submit a Pull Request.

## Usage
If you are on Windows, you need to install Perl (see [Windows Install](https://github.com/ThePeePs/DigitalBlasphemy-Downloader#windows-install)). The following modules are also requred.<br>
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

Open a cmd prompt and install the required perl modules. (copy/paste below)

    cpan Sys::Hostname::Long Config::IniHash DateTime::Format::Mail HTML::TreeBuilder::XPath Mail::Sender XML::RSS::Parser

Download Git client for windows at: http://windows.github.com and install

Open the "Git Shell" and paste the following:

    git clone https://github.com/ThePeePs/DigitalBlasphemy-Downloader.git db-downloader


If you do not feel comfortable with using Git, you can also use [TortoiseSVN](http://tortoisesvn.net/downloads.html "TortoiseSVN Download link")

Create a new folder, right-click on it, select SVN Checkout.. and paste the following in to URL feed:

    https://github.com/ThePeePs/DigitalBlasphemy-Downloader


Copy or rename db-rss-reader.ini.default to db-rss-reader.ini.<br>
Edit the config (db-rss-reader.ini) to suit your needs. (I suggest using Wordpad or [Notepad++](http://notepad-plus-plus-.org/download/v6.5.3.html "Notepad++ Website"))

To run the scipt. open a command prompt, and cd to the directory of the script, and enter:

    perl db-rss-reader.pl

I suggest you set it up as a scheduled task to run at least once a week.




### Linux Install (Debian/Ubuntu)

    sudo apt-get install git libconfig-inihash-perl libwww-perl libhtml-treebuilder-xpath-perl libmail-sender-perl 
    sudo cpan DateTime::Format::Mail XML::RSS::Parser

Clone the repo.

    git clone https://github.com/ThPeePs/DigitalBlasphemy-Downloader.git

Copy or rename db-rss-reader.ini.default to db-rss-reader.ini.<br>
Edit the config (db-rss-reader.ini) to suit your needs.

Then run the script from it's directory.

    perl db-rss-reader.pl

I suggest you set it up as a cron job to run at least once a week.



##### Donations welcome:
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>

LTC - LeY83s2QE83MruyNsJjfcsJYiKF9fRxhNM<br>
CAT - 9rNerHqUTcoLPGtiUxiR3L6onAxe1MRBst<br>
TAG - TBgDDevQrgnP9adAeWyLTYJkw4YhDzsNPS<br>
