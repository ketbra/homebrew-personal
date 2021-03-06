class Colordiff < Formula
  homepage 'http://www.colordiff.org/'
  url 'http://www.colordiff.org/colordiff-1.0.13.tar.gz'
  sha1 '64e369aed2230f3aa5f1510b231fcac270793c09'

  bottle do
    cellar :any
    sha1 "b4715b46336a19e8580a1978be0efa815f4f0f3d" => :yosemite
    sha1 "724512050ef11d4b0f99eb46b2fa98a44520e5a6" => :mavericks
    sha1 "7cf723ad9a524e8b7159c57e7a7d97687c3df067" => :mountain_lion
    sha1 "37447591b2cea0958f2f695ad9a56012cc4cba9b" => :lion
  end

  # Fixes the path to colordiffrc.
  # Uses git-diff colors due to Git popularity.
  # Improves wdiff support through better regular expressions.
  patch :DATA

  def install
    bin.install "colordiff.pl" => "colordiff"
    bin.install "cdiff.sh" => "cdiff"
    etc.install "colordiffrc"
    etc.install "colordiffrc-lightbg"
    man1.install "colordiff.1"
    man1.install "cdiff.1"
  end

  test do
    cp HOMEBREW_PREFIX+'bin/brew', 'brew1'
    cp HOMEBREW_PREFIX+'bin/brew', 'brew2'
    system "#{bin}/colordiff", 'brew1', 'brew2'
  end
end
__END__
diff --git i/colordiff.pl w/colordiff.pl
index 79376b5..8cece49 100755
--- i/colordiff.pl
+++ w/colordiff.pl
@@ -23,6 +23,7 @@

 use strict;
 use Getopt::Long qw(:config pass_through no_auto_abbrev);
+use File::Basename;
 use IPC::Open2;

 my $app_name     = 'colordiff';
@@ -64,7 +65,7 @@ my $cvs_stuff  = $colour{green};

 # Locations for personal and system-wide colour configurations
 my $HOME   = $ENV{HOME};
-my $etcdir = '/etc';
+my $etcdir = dirname(__FILE__) . "/../etc";
 my ($setting, $value);
 my @config_files = ("$etcdir/colordiffrc");
 push (@config_files, "$ENV{HOME}/.colordiffrc") if (defined $ENV{HOME});
@@ -480,8 +481,8 @@ foreach (@inputstream) {
         }
     }
     elsif ($diff_type eq 'wdiff') {
-        $_ =~ s/(\[-.+?-\])/$file_old$1$colour{off}/g;
-        $_ =~ s/(\{\+.+?\+\})/$file_new$1$colour{off}/g;
+        $_ =~ s/(\[-([^-]*(-[^]])?)*-\])/$file_old$1$colour{off}/g;
+        $_ =~ s/(\{\+([^+]*(\+[^}])?)*\+\})/$file_new$1$colour{off}/g;
     }
     elsif ($diff_type eq 'debdiff') {
         $_ =~ s/(\[-.+?-\])/$file_old$1$colour{off}/g;
diff --git i/colordiffrc w/colordiffrc
index 4bcb02d..c46043e 100644
--- i/colordiffrc
+++ w/colordiffrc
@@ -23,7 +23,7 @@ diff_cmd=diff
 # this, use the default output colour"
 #
 plain=off
-newtext=blue
+newtext=green
 oldtext=red
-diffstuff=magenta
-cvsstuff=green
+diffstuff=cyan
+cvsstuff=magenta
