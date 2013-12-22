require 'formula'

class Flickrms < Formula
  homepage 'https://github.com/patrickjennings/FlickrMS'
  url 'https://github.com/patrickjennings/FlickrMS.git', :revision => '757988f'
  head 'https://github.com/patrickjennings/FlickrMS.git'
  version '757988f'

  depends_on 'pkg-config' => :build
  depends_on 'osxfuse'
  depends_on 'glib'
  depends_on 'flickcurl'

  def patches
    # Make it build on Mac OS X.
    DATA
  end

  def install
    system "make"
    bin.install "src/flickrms"
  end

  test do
    system "flickrms", "--version"
  end
end
__END__
diff --git i/src/Makefile w/src/Makefile
index 4746f55..1707d7f 100644
--- i/src/Makefile
+++ w/src/Makefile
@@ -1,7 +1,5 @@
 CC:=gcc

-export PKG_CONFIG_PATH:=/usr/local/lib/pkgconfig
-
 FUSEINC:=`pkg-config --cflags --libs fuse`
 GLIBINC:=`pkg-config --cflags --libs glib-2.0`
 FLKCINC:=`pkg-config --cflags --libs flickcurl`
@@ -9,7 +7,7 @@ CURLINC:=`pkg-config --cflags --libs libcurl`
 INCLUDES:=$(FUSEINC) $(GLIBINC) $(FLKCINC) $(CURLINC)

 OPTS:=-march=native -O2 -pipe
-CFLAGS:=-Wall -W -Werror -Wextra -g
+CFLAGS:=-Wall -W -Werror -Wextra -g -D_POSIX_C_SOURCE=200112L

 OBJS:=flickrms.o cache.o wget.o conf.o

