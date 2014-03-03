function config.locale () {
  #locale -a
  #cat /etc/locale.gen | grep pt_BR.UTF-8
  sed -ri 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen
  locale-gen
  #sed -ri 's/pt_BR.UTF-8 UTF-8/# pt_BR.UTF-8 UTF-8/' /etc/locale.gen
  #locale-gen pt_BR.UTF-8
  #dpkg-reconfigure locales
}
