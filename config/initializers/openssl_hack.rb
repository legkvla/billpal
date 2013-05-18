module OpenSSL
  module SSL
    remove_const :VERIFY_PEER

    VERIFY_PEER = VERIFY_NONE
  end
end
