{ pkgs, ... }: {
  options = { };

  config = {
    # ensure mutt is available in the user's profile too
    home.packages = with pkgs; [ mutt urlview ];

    # Replace the contents below with the full contents of your existing ~/.muttrc
    # cat /run/secrets/muttwords
    home.file.".muttrc".text = ''
      # kreator's Muttrc
      # works with Gmail, has some nice 256 colors.
      # I use the rxvt-unicode 256 color version, which is just urxvt
      # with a 256 color patch.
      
      # ktr - set the shell environment variables 
      #       EMAIL should be the complete gmail email address.
      #       PASSWD should be your gmail password.
      # ktr - if you leave the variables blank, mutt will ask
      #       you when you username which should be your full
      #       email address and password, at the start.
      # ktr - this was already in my distro, which is Archlinux.
      #source "gpg --decrypt --use-agent ~/.mutt/muttwords.gpg |"
      source "cat /run/secrets/muttwords |"
      # to add 'p' option to while sending mail.
      #source ~/.mutt/gpg.rc
      
      # ktr - changing the postponed directory to a local directory.
      #       this is so if there is no connection it doesn't lag.
      #set postponed=imaps://imap.gmail.com/[Gmail]/Drafts
      set postponed="~/.mutt/postponed"
      
      # ktr - this next line speeds up imap with a cache.
      set header_cache=~/.mutt/cache/headers
      set message_cachedir=~/.mutt/cache/bodies
      set certificate_file=~/.mutt/certificates
      set imap_keepalive = 300
      
      set imap_peek = no # ktr - don't mark mail as read whenever fetch mail from server.
      
      # ktr - deeper pipeline makes imap feel faster (default:15)
      #       set this to 0 if having problems with that server.
      set imap_pipeline_depth = 30
      
      
      #########################################
      # ktr - Auto view emails with html in
      # them with a text browser..
      #
      # ktr - in your ~/.mailcap file add:
      # text/html;   w3m %s; nametemplate=%s.html
      # text/html;   w3m -dump %s; nametemplate=%s.html; copiousoutput
      #
      # ktr - below is what it was before.
      auto_view text/html image/*
      #auto_view text/html  # view html automatically
      alternative_order text/plain text/enriched text/html # save html las
      
      # this doesn't work -- so no function collapse-parts
      #bind attach 'V' "<collapse-parts>"
      macro pager \cv "<pipe-message>iconv -c --to-code=UTF8 > /tmp/mail-tmp1.html<enter><shell-escape>firefox /tmp/mail-tmp1.html 2>/dev/null &<enter>"
      
      macro attach 'v' "<pipe-entry>iconv -c --to-code=UTF8 > /tmp/mail-mutt-tmp.html\n<shell-escape>firefox /tmp/mail-mutt-tmp.html &>/dev/null &<enter>"
      
      #########################################
      #########################################
      # Mutt Theme and Colors
      #
      #set sort=threads
      #set sort_aux = 'last-date-received'
      
      set sort=threads
      set sort_aux = 'reverse-date-received'
      
      set pager_index_lines=0		#You might want to increase this
      set pager_context=1
      set index_format='%4C %Z %{%b %d} %-15.15F (%4l) %s'
      set markers=no # don't put '+' at the beginning of wrapped lines
      set smart_wrap # make reading more comfortable.
      
      # Header stuff
      ignore "Authentication-Results:"
      ignore "DomainKey-Signature:"
      ignore "DKIM-Signature:"
      hdr_order Date From To Cc
      
      ignore *
      unignore from: date subject to cc
      unignore x-mailing-list: posted-to:
      unignore x-mailer:
      
      
      ##########################################
      # My Rolodeck :)
      #set alias_file= ~/.mutt/aliases
      #set sort_alias= alias
      #set reverse_alias=yes
      #source $alias_file
      ##########################################
      # In Sent box display receipient instead
      # of the sender
      # ktr - this regex appears to be invalid for now take it out.
      #folder-hook   *[sS]ent* 'set index_format="%2C | %Z [%d] %-30.30t (%-4.4c) %s"'
      #folder-hook ! *[sS]ent* 'set index_format="%2C | %Z [%d] %-30.30F (%-4.4c) %s"'
      
      ########################################## 
      ##########################################
      ## ktr - my fucntions!
      #
      set pager_stop = yes
      set delete = yes
      set editor='vim + -c "set textwidth=72" -c "set wrap" -c "set nocp" -c "?^$"'
      #set editor='nvim + -c "set textwidth=72" -c "set wrap" -c "set nocp" %s'
      
      ######################
      # ktr - my key bindings
      bind pager j next-line
      bind pager k previous-line
      bind pager g top
      bind pager G bottom
      
      bind index g first-entry
      bind index G last-entry
      
      ############################
      # ktr - MAILING LIST stuff
      subscribe aklug@aklug.org
      subscribe fulldisclosure@seclists.org
      
      
      # gruvbox dark (contrast dark):
      
      # bg0    = 234
      # bg1    = 237
      # bg2    = 239
      # bg3    = 241
      # bg4    = 243
      # 
      # gray   = 245
      # 
      # fg0    = 229
      # fg1    = 223
      # fg2    = 250
      # fg3    = 248
      # fg4    = 246
      # 
      # red    = 167
      # green  = 142
      # yellow = 214
      # blue   = 109
      # purple = 175
      # aqua   = 108
      # orange = 208
      
      
      # See http://www.mutt.org/doc/manual/#color
      
      color attachment  color109 color234
      color bold        color229 color234
      color error       color167 color234
      color hdrdefault  color246 color234
      color indicator   color223 color237
      color markers     color243 color234
      color normal      color223 color234
      color quoted      color250 color234
      color quoted1     color108 color234
      color quoted2     color250 color234
      color quoted3     color108 color234
      color quoted4     color250 color234
      color quoted5     color108 color234
      color search      color234 color208
      color signature   color108 color234
      color status      color234 color250
      color tilde       color243 color234
      color tree        color142 color234
      color underline   color223 color239
      
      color sidebar_divider    color250 color234
      color sidebar_new        color142 color234
      
      color index color142 color234 ~N
      color index color108 color234 ~O
      color index color109 color234 ~P
      color index color214 color234 ~F
      color index color175 color234 ~Q
      color index color167 color234 ~=
      color index color234 color223 ~T
      color index color234 color167 ~D
      
      color header color214 color234 "^(To:|From:)"
      color header color142 color234 "^Subject:"
      color header color108 color234 "^X-Spam-Status:"
      color header color108 color234 "^Received:"
      
      # Regex magic for URLs and hostnames
      #
      # Attention: BSD's regex has RE_DUP_MAX set to 255.
      #
      # Examples:
      #   http://some-service.example.com
      #   example.com
      #   a.example.com
      #   some-service.example.com
      #   example.com/
      #   example.com/datenschutz
      #   file:///tmp/foo
      #
      # Non-examples:
      #   1.1.1900
      #   14.02.2022/24:00
      #   23.59
      #   w.l.o.g
      #   team.its
      color body color142 color234 "[a-z]{3,255}://[[:graph:]]*"
      color body color142 color234 "([-[:alnum:]]+\\.)+([0-9]{1,3}|[-[:alpha:]]+)/[[:graph:]]*"
      color body color142 color234 "([-[:alnum:]]+\\.){2,255}[-[:alpha:]]{2,10}"
      
      # IPv4 and IPv6 stolen from https://stackoverflow.com/questions/53497/regular-expression-that-matches-valid-ipv6-addresses
      color body color142 color234 "((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
      color body color142 color234 "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"
      
      # Mail addresses and mailto URLs
      color body color208 color234 "[-a-z_0-9.%$]+@[-a-z_0-9.]+\\.[-a-z][-a-z]+"
      color body color208 color234 "mailto:[-a-z_0-9.]+@[-a-z_0-9.]+"
      
      # some simleys and stuff
      color body color234 color214 "[;:]-*[)>(<lt;|]"
      color body color229 color234 "\\*[- A-Za-z]+\\*"
      
      color body color214 color234 "^-.*PGP.*-*"
      color body color142 color234 "^gpg: Good signature from"
      color body color167 color234 "^gpg: Can't.*$"
      color body color214 color234 "^gpg: WARNING:.*$"
      color body color167 color234 "^gpg: BAD signature from"
      color body color167 color234 "^gpg: Note: This key has expired!"
      color body color214 color234 "^gpg: There is no indication that the signature belongs to the owner."
      color body color214 color234 "^gpg: can't handle these multiple signatures"
      color body color214 color234 "^gpg: signature verification suppressed"
      color body color214 color234 "^gpg: invalid node with packet of type"
      
      color body color142 color234 "^Good signature from:"
      color body color167 color234 "^.?BAD.? signature from:"
      color body color142 color234 "^Verification successful"
      color body color167 color234 "^Verification [^s][^[:space:]]*$"
      
      color compose header            color223 color234
      color compose security_encrypt  color175 color234
      color compose security_sign     color109 color234
      color compose security_both     color142 color234
      color compose security_none     color208 color234
      # --- end of .muttrc content ---
    '';
  };
}
      
