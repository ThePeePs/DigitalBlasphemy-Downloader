#!/usr/bin/perl -w

use bigint;
use Sys::Hostname::Long;
use Config::IniHash;
use LWP;
use LWP::Authen::Basic;
use HTML::TreeBuilder::XPath;
use HTML::Parser;
use HTML::Entities;
use XML::RSS::Parser;
use DateTime::Format::Mail;
use FileHandle;
use Tie::File;
use Mail::Sender;
use File::Path qw(make_path remove_tree);
our $version = '0.1a';

# TODO Add option to download zip files, and sort files to correct folders.
# TODO Add automatic checking of github repo for updates.
# TODO Cleanup email body.

# Load variables from config file.
$cfg = ReadINI('db-rss-reader.ini',
    forValue => sub {
        my ($name, $value, $sectionname, $INIhashref) = @_;
        $value =~ s/\s*;.*$//;
        return $value;
    }
);
$dbuser = $cfg->{'dbinfo'}->{'user'};
$dbpass = $cfg->{'dbinfo'}->{'pass'};
$retries = $cfg->{'dbinfo'}->{'retries'};
$blurb = $cfg->{'dbinfo'}->{'blurb'};
$useproxy = $cfg->{'proxy'}->{'use'};
@proxy = $cfg->{'proxy'}->{'server'};
$sendmail = $cfg->{'mail'}->{'send'};
$mailto = $cfg->{'mail'}->{'to'};
$mailfrom = $cfg->{'mail'}->{'from'};
$mailsrv = $cfg->{'mail'}->{'srv'};
$mailport = $cfg->{'mail'}->{'port'};
$mailauthreq = $cfg->{'mail'}->{'authreq'};
$mailauthtype = $cfg->{'mail'}->{'authtype'};
$mailauthdomain = $cfg->{'mail'}->{'authdomain'};
$mailuser = $cfg->{'mail'}->{'user'};
$mailpass = $cfg->{'mail'}->{'pass'};
$datadir = $cfg->{'filepath'}->{'datadir'};
$basedir = $cfg->{'filepath'}->{'basedir'};
$logenabled = $cfg->{'logging'}->{'enabled'};
$logfile = $cfg->{'logging'}->{'logfile'};
$consolelog = $cfg->{'logging'}->{'consolelog'};
$dlsizes = $cfg->{'dlsizes'};


if (!defined $basedir || !defined $datadir) {
    print "File pathes have not been set!!\nDid you edit the config file?\n";
    exit 3;
};

# Paths to all image sizes.
# DO NOT EDIT THIS!
%imgsizes = ('320x480'    => 'graphics/320x480/IMGNAME320x480.jpg',
             '360x480'    => 'graphics/360x480/IMGNAME360x480.jpg',
             '480x272'    => 'graphics/480x272/IMGNAME480x272.jpg',
             '480x320'    => 'graphics/480x320/IMGNAME480x320.jpg',
             '480x360'    => 'graphics/480x360/IMGNAME480x360.jpg',
             '480x800'    => 'graphics/480x800/IMGNAME480x800.jpg',
             '640x480'    => 'graphics/640x480/IMGNAME640x480.jpg',
             'timeline'   => 'graphics/fbt/IMGNAMEfbt.jpg',
             '640x1136'   => 'content/jpgs/640x1136/IMGNAME640x1136.jpg',
             '750x1344'   => 'content/jpgs/750x1344/IMGNAME750x1344.jpg',
             '1920x1920'  => 'content/jpgs/1920x1920/IMGNAME1920x1920.jpg',
             '960x544'    => 'content/jpgs/960x544/IMGNAME960x544.jpg',
             '960x800'    => 'content/jpgs/960x800/IMGNAME960x800.jpg',
             '960x854'    => 'content/jpgs/960x854/IMGNAME960x854.jpg',
             '1440x1280'  => 'content/jpgs/1440x1280/IMGNAME1440x1280.jpg',
             '1080x1920'  => 'content/jpgs/1080x1920/IMGNAME1080x1920.jpg',
             '1024x1024'  => 'content/jpgs/1024x1024/IMGNAME1024x1024.jpg',
             '2160x1440'  => 'content/jpgs/2160x1440/IMGNAME2160x1440.jpg',
             '2048x2048'  => 'content/jpgs/2048x2048/IMGNAME2048x2048.jpg',
             '1024x768'   => 'content/jpgs/1024st/IMGNAME1024st.jpg',
             '1152x864'   => 'content/jpgs/db/IMGNAME.jpg',
             '1600x1200'  => 'content/jpgs/1600/IMGNAME1600.jpg',
             '1280x1024'  => 'content/jpgs/1280/IMGNAME1280.jpg',
             '1024x600'   => 'content/jpgs/1024/IMGNAME1024.jpg',
             '1280x800'   => 'content/jpgs/1280w/IMGNAME1280w.jpg',
             '1366x768'   => 'content/jpgs/1366/IMGNAME1366.jpg',
             '1600x900'   => 'content/jpgs/1600x900/IMGNAME1600x900.jpg',
             '1920x1080'  => 'content/jpgs/1080p/IMGNAME1080p.jpg',
             '2560x1440'  => 'content/jpgs/1440p/IMGNAME1440p.jpg',
             '2560x1440L' => 'content/png/IMGNAME1440p.png',
             '1440x900'   => 'content/jpgs/1440/IMGNAME1440.jpg',
             '1680x1050'  => 'content/jpgs/1680/IMGNAME1680.jpg',
             '1920x1200'  => 'content/jpgs/widescreen/IMGNAME1920.jpg',
             '2560x1600'  => 'content/jpgs/widescreen/IMGNAME2560.jpg',
             '2560x1600L' => 'content/png/IMGNAME2560.png',
             '2880x1800'  => 'content/jpgs/widescreen/IMGNAME2880.jpg',
             '2880x1800L' => 'content/png/IMGNAME2880.png',
             '4096x2304'  => 'content/jpgs/4k/IMGNAME4ktv.jpg',
             '4096x2560'  => 'content/jpgs/4k/IMGNAME4k.jpg',
             '2560x1024'  => 'content/jpgs/2x/IMGNAME2x2560.jpg',
             '3200x1200'  => 'content/jpgs/2x/IMGNAME2x.jpg',
             '3840x1080'  => 'content/jpgs/2x/IMGNAME2x1080p.jpg',
             '5120x1440'  => 'content/jpgs/2x/IMGNAME2x1440p.jpg',
             '3360x1050'  => 'content/jpgs/2x/IMGNAME2x3360.jpg',
             '3840x1200'  => 'content/jpgs/2x/IMGNAME2x3840.jpg',
             '5120x1600'  => 'content/jpgs/2x/IMGNAME2x5120.jpg',
             '8192x2560'  => 'content/jpgs/2x/IMGNAME4k2x.jpg',
             '3840x1024'  => 'content/jpgs/3x/IMGNAME3x3840.jpg',
             '4800x1200'  => 'content/jpgs/3x/IMGNAME3x.jpg',
             '5760x1080'  => 'content/jpgs/3x/IMGNAME3x1080p.jpg',
             '7680x1440'  => 'content/jpgs/3x/IMGNAME3x1440p.jpg',
             '5040x1050'  => 'content/jpgs/3x/IMGNAME3x5040.jpg',
             '5760x1200'  => 'content/jpgs/3x/IMGNAME3x5760.jpg',
             '7680x1600'  => 'content/jpgs/3x/IMGNAME3x7680.jpg',
             '12288x2560' => 'content/jpgs/3x/IMGNAME4k3x.jpg');

# Create Directories and files if they don't exist.
if ( !-e $datadir ) {
    make_path $datadir;
};
if ( !-e $basedir ) {
    make_path $basedir;
};
if ( !-e "$datadir/dllist.txt" ) {
    open(DL,">","$datadir/dllist.txt") or die "Unable to create $datadir/dlllist.txt: $!\n";
    close(DL);
};
if ( !-e "$datadir/xmlmod.txt" ) {
    open (XM,">","$datadir/xmlmod.txt") or &write_log("WARNING: Unable to create $datadir/xmlmod.txt: $!\n",0);
    print XM "0";
    close(XM);
};

# Setup work some variables
$dlcount = keys(%$dlsizes);
@imgdld = ();
@sizesdld = ();
@imgblurb = ();
@feedlist = ();
$skip = 0;
open ($rssmod,"+<","$datadir/xmlmod.txt") or &write_log("WARNING: Unable to open $datadir/xmlmod.txt: $!\n",0);
$modtime = <$rssmod>;

# Get RSS Feed and save it to a file.
&write_log("Getting RSS feed from Digital Blasphemy.\n",0);
$ua = new LWP::UserAgent;
$ua->agent('DB-AutoDownloader/'.$version.' ');
if ( $useproxy eq 'yes' ) {
    $ua->proxy(@proxy);
};
$rssurl = 'http://www.digitalblasphemy.com/rss/db.xml';
$rssreq = new HTTP::Request('GET', $rssurl);
$rssresp = $ua->request($rssreq, "$datadir/feed.xml");
$rssheaders = $rssresp->headers;
if ( $rssresp->code != 200 ) {
    &write_log("Unable to download RSS feed.\n",0);
    &write_log('HTTP error '.$rssresp->code.': '.$rssresp->message."\n",0);
    exit 1;
}
else {
    &write_log("Download of RSS feed sucessfull.\n",0);
    if ( $modtime == $rssheaders->last_modified ) {
        &write_log("RSS feed has not been updated since last check.\n",0);
        $skip = 1;
    }
    else {
        seek($rssmod,0,0);
        print $rssmod $rssheaders->last_modified
    };
    
};
close($rssmod);

# If the RSS feed has not been updated from the last time we checked,
# skip processing the feed, as nothing has changed.
if ( $skip == 0 ) {

    # Parse the RSS XML, and find new entries.
    &write_log("Parsing RSS XML file, please standby...\n",0);
    $pxml = XML::RSS::Parser->new;
    $xmlfh = FileHandle->new("$datadir/feed.xml");
    $feed = $pxml->parse_file($xmlfh);

    tie @dllist, 'Tie::File', "$datadir/dllist.txt" or die "Cannot open $datadir/dllist.txt: $!\n";
    $histcnt = @dllist;
    foreach $i ( $feed->query('//item') ) { 
        $pdate = $i->query('pubDate');
        $title = $i->query('title');
        $des = $i->query('description');
        $guid = $i->query('guid');

        # If the item's <guid> tag contains "preview" then parse the item for the new image.
        if ( $guid->text_content =~ /preview/ ) {
            $guidtxt = $guid->text_content;
            $guidtxt =~ s/.*i=//;
            $imgname = $guidtxt;
            $imgname =~ s/#.*//;
            push(@feedlist, $imgname);
            $destxt = $des->text_content;
            $imgtxt = &get_blurb();
            $dt = DateTime::Format::Mail->parse_datetime($pdate->text_content);
            $dte = $dt->epoch;
            $check = 0;
            $n = 0;

            # Check to see if have downloaded any of the sizes yet, and if so, do we have them all?
            # If not, download all the sizes selected.
            foreach $line (@dllist) {
                $match = grep(/$guidtxt,$dte/, $line);
                if ($match == 1) {
                    @info = split(/,/, $line);

                    # We have all sizes of the img, and the number of sizes to download has not changed
                    if ( $info[1] == $dt->epoch && $info[2] == $dlcount && $info[3] == (2 ** $dlcount - 1) ) {
                        &write_log("We have all sizes for $imgname already, moving on to the next.\n",0);
                        $check = 1;
                    }
                    # We have some of the sizes of the img, the number of sizes has not changed, and we have not exceeded the max num of retries.
                    elsif ( $info[1] == $dt->epoch && $info[2] == $dlcount && $info[3] != (2 ** $dlcount - 1) && $info[4] < $retries ) {
                        &write_log("We have some of the sizes for $imgname, retrying...\n",0);
                        $check = 2;
                        $l = $n;
                    }
                    # Max number of retry attempts meet, we will not try again.
                    elsif ( $info[1] == $dt->epoch && $info[2] == $dlcount && $info[3] != (2 ** $dlcount - 1) && $info[4] > $retries ) {
                        &write_log("Max number of retries for $imgname reached. No more attempts will be made.\n",0);
                    }
                    # The number sizes has changed.
                    else {
                        $check = 3;
                        &write_log("Image size selection has changed, retrying all sizes...\n",0);
                        $l = $n;
                    };
                };
                $n++;
            };
            
            # Download the selected size images.
            $ua->credentials('www.digitalblasphemy.com:80', 'DB Member', $dbuser => $dbpass);
            if ( $check == 0 ) {
                $dlresults = &download_imgs($imgname);
                push(@imgdld, $title->text_content);
                push(@sizesdld, $dlresults);
                push(@imgblurb, $imgtxt);
                if ( $histcnt == 0 ) {
                    push(@dllist, "$guidtxt,$dte,$dlcount,$dlresults,1");
                }
                else {
                    unshift(@dllist, "$guidtxt,$dte,$dlcount,$dlresults,1");
                };
            };
            if ( $check == 2 ) {
                (undef,undef,undef,$dlstatus,$retry) = split(/,/, $dllist[$l]);
                $dlresults = &retry_download($imgname,$dlstatus);
                $retry++;
                push(@imgdld, $title->text_content);
                push(@sizesdld, $dlresults);
                push(@imgblurb, $imgtxt);
                $dllist[$l] = "$guidtxt,$dte,$dlcount,$dlresults,$retry";
            };
            if ( $check == 3 ) {
                $dlresults = &download_imgs($imgname);
                push(@imgdld, $title->text_content);
                push(@sizesdld, $dlresults);
                push(@imgblurb, $imgtxt);
                $dllist[$l] = "$guidtxt,$dte,$dlcount,$dlresults,1";
            };
        };
    };
    
    # Remove any items from the download list that are no longer in the RSS feed.
    $l = 0;
    foreach $line (@dllist) {
        $remove = 0;
        foreach $item (@feedlist) {
            $imatch = grep(/$item/, $line);
            if ( $imatch == 1 ) {
                $remove++;
            };
        };
        if ( $remove == 0 ) {
            splice(@dllist,$l,1);
        };
        $l++;
    };
    untie @dllist;
};

# Prep body of email.
if ( $sendmail eq 'yes' && $skip == 0 ) {
    $imgcount = @imgdld;
    $emailtxt = "<h2>Results of Downloads</h2>\n\n";
    for ($c=0; $c<$imgcount; $c++) {
        $emailtxt .= "<h3 align=\"center\">${imgdld[$c]}</h3>\n\n";
        $emailtxt .= "<p>${imgblurb[$c]}</p>\n\n";
        @bresults = &dec_to_bin($sizesdld[$c]);
        $b = 0;
        $emailtxt .= "<table border=\"0\" cellspacing=\"0\" cellpadding=\"5\"><tr><th>".sprintf("%-13s","Resolution")."</th><th>Downloaded</th></tr>\n";
        foreach $size (keys %$dlsizes) {
            if ( $bresults[$b] == 0 ) {
                $emailtxt .= "<tr><td>".sprintf("%-13s",$size)."</td><td><font color=\"red\"".&bit_to_txt($bresults[$b])."</font></td></tr>\n";
            }
            else {
                $emailtxt .= "<tr><td>".sprintf("%-13s",$size)."</td><td><font color=\"green\">".&bit_to_txt($bresults[$b])."</font></td></tr>\n";
            };
            $b++;
        };
        $emailtxt .= "</table>\n\n";
    };    
    $html = "<html>\n<p>\n$emailtxt</p>\n</html>\n";

    # Create plain text from html.
    $plain = '';
    $p = HTML::Parser->new(text_h => [\&text_rtn, 'text']);
    $p->parse($emailtxt);

    # Create the mail object and send the email.
    $host = hostname_long;
    $Mail::Sender::SITE_HEADERS = "X-Mailer: Mail::Sender version $Mail::Sender::VERSION, db-rss-reader version $version";
    $Mail::Sender::NO_X_MAILER = 1;
    if ( $mailauthreq eq 'yes' ) {
        $mail = new Mail::Sender {
            auth => $mailauthtype,
            authid => $mailuser,
            authpwd => $mailpass,
            authdomain => $mailauthdomain,
        };
    }
    else { 
        $mail = new Mail::Sender;
    };
    $mail->OpenMultipart({
        to => $mailto,
        from => $mailfrom,
        subject => 'New Images downloaded from Digital Blasphemy',
        smtp => $mailsrv,
        port => $mailport,
        client => $host,
        multipart => 'mixed',
    });
    $mail->Part({ctype => 'multipart/alternative'});
    $mail->Part({ctype => 'text/plain', dispostion => 'NONE', msg => $plain });
    $mail->Part({ctype => 'text/html', dispostion => 'NONE', msg => $html});
    $mail->EndPart('mulitpart/alternative');
    if ( $mail->Close ) {
        &write_log("Mail send OK.\n",0)
    }
    else {
        &write_log("Error sending mail: $Mail::Sender::Error \n",0)
    };
};

exit 0;
# End of script.


# Subroutines
############################################

# Download new images (first try)
sub download_imgs($) {
    my $imgname = shift;
    my $b = 0;
    my $results = 0;
    while ( (my $dlkey, my $dlval) = each(%$dlsizes) ) {
        (my $uri = $imgsizes{$dlkey}) =~ s/IMGNAME/$imgname/;
        (my $imgpath = $dlval) =~ s/\/IMG.*//;
        if ( !-e "$basedir/$imgpath" ) {
            make_path "$basedir/$imgpath";
        };
        $dlval =~ s/IMGNAME/$imgname/;
        # If the file does not already exit, try to download it.
        if ( !-e "$basedir/$dlval" ) {
            &write_log("Downloading $imgname at $dlkey... ",0);
            my $dlreq = new HTTP::Request('GET', "http://www.digitalblasphemy.com/$uri");
            my $dlres = $ua->request($dlreq, "$basedir/$dlval");
            # Check to see that we got an OK response, and that the size of the file matches
            # what the server says it should be.
            if ( $dlres->code == 200 ) {
                if ( -s "$basedir/$dlval" == $dlres->headers->content_length ) {
                    $results += 2 ** $b;
                    &write_log("Success\n",1);
                }
                else {
                    &write_log("Failed, File download incomplete.\n",1);
                    unlink "$basedir/$dlval" or &write_log("WARNING: Could not delete incomplete image $basedir/$dlval: $!\n",0);
                    };
            }
            else {
                &write_log('Failed, HTTP Error '.$dlres->code.': '.$dlres->message."\n",1);
            };
        }
        else {
            &write_log("File for $imgname at $dlkey exists, moving on to next.\n",0);
            $results += 2 ** $b;
        };
        # Sleep for 4 seconds to prevent DoS like downloading.
        sleep(4);
        $b++;
    };
    return $results;
}

# Download new images (retry)

sub retry_download($) {
    my $imgname = shift;
    my $status = shift;
    my @bstatus = &dec_to_bin($status);
    my @bresults = @bstatus;
    my $b = 0;
    while ( (my $dlkey, my $dlval) = each(%$dlsizes) ) {
        (my $uri = $imgsizes{$dlkey}) =~ s/IMGNAME/$imgname/;
        (my $imgpath = $dlval) =~ s/\/IMG.*//;
        if ( !-e "$basedir/$imgpath" ) {
            make_path "$basedir/$imgpath";
        };
        $dlval =~ s/IMGNAME/$imgname/;
        # If the file does not already exit, try to download it.
        if ( !-e "$basedir/$dlval" && $bstatus[$b] != 1 ) {
            &write_log("Downloading $imgname at $dlkey... ",0);
            my $dlreq = new HTTP::Request('GET', "http://www.digitalblasphemy.com/$uri");
            my $dlres = $ua->request($dlreq, "$basedir/$dlval");
            # Check to see that we got an OK response, and that the size of the file matches
            # what the server says it should be.
            if ( $dlres->code == 200 ) {
                if ( -s "$basedir/$dlval" == $dlres->headers->content_length ) {
                    $bresults[$b] = 1;
                    &write_log("Success\n",1);
                }
                else {
                    &write_log("Failed, File download incomplete.\n",1); 
                    unlink "$basedir/$dlval" or &write_log("WARNING: Could not delete incomplete image $basedir/$dlval: $!\n",0);
                };
            }
            else {
                &write_log('Failed, HTTP Error '.$dlres->code.': '.$dlres->message."\n",1);
            };
        }
        else {
            &write_log("File for $imgname at $dlkey not marked for retry.\n",0);
            if ( -e "$basedir/$dlval" ) {
                $bresults[$b] = 1;
            };
        };
        # Sleep for 4 seconds to prevent DoS like downloading.
        sleep(4);
        $b++;
    };
    $results = &bin_to_dec(@bresults);
    return $results;
}

# Get the blurb Ryan writes about his new render.
sub get_blurb($) {
    my $blob;
    if ( $blurb eq 'rss' ) {
        $blob = $destxt;
        $blob =~ s/\n/ /msg;
        $blob =~ s/  / /g;
        $blob =~ s/fb\/${imgname}fb\.jpg/480x272\/${imgname}480x272.jpg/;
    }
    elsif ( $blurb eq 'site' ) {
        my $imgurl = 'http://digitalblasphemy.com/preview.shtml?i='.$imgname;
        my $htmlreq = new HTTP::Request('GET', $imgurl);
        my $htmlresp = $ua->request($htmlreq);
        my $page = $htmlresp->content;
        my $phtml = HTML::TreeBuilder::XPath->new_from_content( $page);
        my @storys = $phtml->findnodes( '//div[@class="story"]');
        foreach my $story (@storys) {
            $blob = $story->as_HTML;
        };
    };
    return $blob;
}

sub dec_to_bin($) {
    my $dldec = shift;
    my $bstr = unpack("b48", pack("I", $dldec)); 
    $bstr = reverse($bstr);
    my @bits = split(//,substr($bstr, -$dlcount)); 
    return @bits;
}
    
sub bin_to_dec($) {
    my @bits = @_;
    my $bstr = join("", @bits);
    $bstr = reverse($bstr);
    my $dldec = oct "0b$bstr";
    return $dldec;
}

sub bit_to_txt($) {
    my $bit = shift;
    if ( $bit == 0 ) { 
        return 'Failed';
    }
    else {
        return 'Success';
    };
}

sub write_log($) {
    my $s = shift;
    my $append = shift;
    if ( $logenabled eq 'yes' ) {
        my @abbr = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
        my ($logsec,$logmin,$loghour,$logmday,$logmon,$logyear,$logwday,$logyday,$logisdst)=localtime(time);
        my $logtimestamp = sprintf("%s %02d %02d:%02d:%02d",$abbr[$logmon],$logmday,$loghour,$logmin,$logsec);
        my $fh;
        open($fh, '>>', "$datadir/$logfile") or die "$datadir/$logfile: $!";
        if ( $append == 0 ) {
            print $fh "$logtimestamp $s";
        }
        else {
            print $fh "$s";
        };
        close($fh);
        if ( $consolelog eq 'yes' ) {
            print "$s"
        };
    };
}

sub text_rtn {
    foreach (@_) {
        my $line = decode_entities($_);
        $line =~ s/^ *//;
        $plain .= $line;
    };
}

