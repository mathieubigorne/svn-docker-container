# Sets up 

FROM ubuntu:precise

# Install Subversion 1.8 and Apache
RUN apt-get install -y wget
RUN echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
RUN sh -c 'echo "deb http://opensource.wandisco.com/ubuntu precise svn18" >> /etc/apt/sources.list.d/WANdisco.list'
RUN wget -q http://opensource.wandisco.com/wandisco-debian.gpg -O- | apt-key add -
RUN apt-get update -y
RUN apt-get install -y subversion apache2 libapache2-svn

# Create a repo
RUN svnadmin create /home/svn

# Set permissions
RUN addgroup subversion
RUN usermod -a -G subversion www-data
RUN chown -R www-data:subversion /home/svn
RUN chmod -R g+rws /home/svn

# Configure Apache to serve up Subversion
RUN /usr/sbin/a2enmod auth_digest
RUN rm /etc/apache2/mods-available/dav_svn.conf
ADD testrepo-conf/dav_svn.conf /etc/apache2/mods-available/dav_svn.conf

# Create password files. Pre-created with "user"/"pass" username and password.
RUN mkdir -p /etc/subversion
ADD testrepo-conf/passwd.htpasswd /etc/subversion/passwd.htpasswd
ADD testrepo-conf/passwd.htdigest /etc/subversion/passwd.htdigest
ADD testrepo-conf/authz.conf /etc/subversion/authz.conf

ENV APACHE_RUN_USER    www-data
ENV APACHE_RUN_GROUP   www-data
ENV APACHE_PID_FILE    /var/run/apache2.pid
ENV APACHE_RUN_DIR     /var/run/apache2
ENV APACHE_LOCK_DIR    /var/lock/apache2
ENV APACHE_LOG_DIR     /var/log/apache2

EXPOSE 80
