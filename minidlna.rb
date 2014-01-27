require 'formula'

class Minidlna < Formula
  url 'http://downloads.sourceforge.net/project/minidlna/minidlna/1.1.1/minidlna-1.1.1.tar.gz'
  homepage 'http://sourceforge.net/projects/minidlna/'
  sha1 '97c28d2b861957620d319929f904225e906830c7'
  head 'http://git.code.sf.net/p/minidlna/git', :using => :git

  option 'with-tivo', 'Build with TiVo support'

  depends_on 'automake' => :build
  depends_on 'autoconf' => :build
  depends_on 'libtool' => :build
  depends_on 'exif'
  depends_on 'ffmpeg'
  depends_on 'flac'
  depends_on 'jpeg'
  depends_on 'libid3tag'
  depends_on 'libvorbis'

  if build.with? 'with-transcoding'
    head 'https://bitbucket.org/stativ/minidlna-transcode', :using => :hg
    depends_on 'imagemagick'
    depends_on 'libiconv'
    depends_on 'libogg'
  end

  def patches
    [
      # Fix the undeclared 'IFF_SLAVE' build error.
      'https://gist.github.com/sorin-ionescu/8118073/raw/eebb97a57c7af9bec8e7763e622edfce62671f0f/getifaddr.c.patch',
      # Use the Apple icon.
      'https://gist.github.com/sorin-ionescu/8118073/raw/e2c62c5a360dc4bccd52c9af36981f84674c8c4f/icons.c.patch',
      # Enable the '-S' switch to disable forking for launchd.
      'https://gist.github.com/sorin-ionescu/8118073/raw/0a9c88adc99b9571a2a9c553cad29d43e89ac4d8/minidlna.c.patch',
      # Use FSEvents for filesystem notifications.
      'https://gist.github.com/sorin-ionescu/8571424/raw/c103c6cb6d6b0eeadbeeebb46f0657b503cc3bc3/fsevents.patch',
      # Fix transcode patch compilation.
      DATA
    ]
  end

  def install
    inreplace 'minidlna.conf' do |s|
      s.gsub! '#db_dir=/var/cache/minidlna', "db_dir=#{var}/cache/minidlna"
      s.gsub! '#log_dir=/var/log', "log_dir=#{var}/log"
      s.gsub! '#presentation_url=http://www.mylan/index.php', '#presentation_url=http://localhost:8200/'
    end

    if build.with? 'with-transcoding'
      # Fix signal name on Mac OS X.
      inreplace 'transcode.c', 'SIGCLD', 'SIGCHLD'

      # Set transcoders path in configuration file.
      inreplace 'minidlna.conf' do |s|
        s.gsub! 'transcode_audio_transcoder=', "transcode_audio_transcoder=#{opt_prefix}/libexec/minidlna-transcode-audio"
        s.gsub! 'transcode_video_transcoder=', "transcode_video_transcoder=#{opt_prefix}/libexec/minidlna-transcode-video"
        s.gsub! 'transcode_image_transcoder=', "transcode_image_transcoder=#{opt_prefix}/libexec/minidlna-transcode-image"
      end
    end

    # Specify the C langauge version to make it compile.
    ENV.append 'CFLAGS', '-std=gnu89'

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]
    args << "--enable-tivo" if build.with? 'tivo'

    system './autogen.sh'
    system "./configure", *args
    system 'make install'

    etc.install 'minidlna.conf'
    man5.install 'minidlna.conf.5'
    man8.install 'minidlnad.8'

    if build.with? 'with-transcoding'
      libexec.install 'transcodescripts/transcode_audio' => 'minidlna-transcode-audio'
      libexec.install 'transcodescripts/transcode_video' => 'minidlna-transcode-video'
      libexec.install 'transcodescripts/transcode_image' => 'minidlna-transcode-image'
      libexec.install 'transcodescripts/transcode_video-hardcodesub' => 'minidlna-transcode-video-hardcode-subtitles'
    end
  end

  test do
    system "#{sbin}/minidlnad", "-V"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_prefix}/sbin/minidlnad</string>
            <string>-S</string>
            <string>-f</string>
            <string>#{etc}/minidlna.conf</string>
            <string>-P</string>
            <string>#{var}/run/minidlna.pid</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
__END__
diff --git a/libav.h b/libav.h
--- a/libav.h
+++ b/libav.h
@@ -43,10 +43,11 @@

 static inline int
 lav_open(AVFormatContext **ctx, const char *filename)
 {
  int ret;
+ av_register_all();
 #if LIBAVFORMAT_VERSION_INT >= ((53<<16)+(17<<8)+0)
  ret = avformat_open_input(ctx, filename, NULL, NULL);
  if (ret == 0)
    avformat_find_stream_info(*ctx, NULL);
  /*else