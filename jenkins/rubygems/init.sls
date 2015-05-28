# GEMS
gem_chunky_png:
  cmd.run:
    - name: /usr/bin/gem install chunky_png-1.3.3.gem -s salt://jenkins/rubygems/

gem_rb_fsevent:
   cmd.run:
    - name: /usr/bin/gem install rb-fsevent-0.9.4.gem -s salt://jenkins/rubygems/
    
gem_rb_inotify:
   cmd.run:
    - name: /usr/bin/gem install rb-inotify-0.9.5-2.gem -s salt://jenkins/rubygems/
    
gem_ffi:
   cmd.run:
    - name: /usr/bin/gem install ffi-1.9.6-2.gem -s salt://jenkins/rubygems/  

gem_sass:
   cmd.run:
    - name: /usr/bin/gem install sass-3.4.9.gem -s salt://jenkins/rubygems/  

gem_multi_json:
   cmd.run:
    - name: /usr/bin/gem install multi_json -s salt://jenkins/rubygems/ 
    
gem_compass_core:
   cmd.run:
    - name: /usr/bin/gem install compass-core-1.0.1.gem -s salt://jenkins/rubygems/ 

gem_compass:
   cmd.run:
    - name: /usr/bin/gem install compass-1.0.1.gem -s salt://jenkins/rubygems/ 

