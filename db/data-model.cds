namespace my.bookshop;

@requires: 'Admin'
entity Books {
  key ID : Integer;
  title  : String;
  stock  : Integer;
}
