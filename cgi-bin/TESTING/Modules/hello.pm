package hello;

sub sayHello {
    my($class, $user) = @_;
	return "$class, $user";
    return "Hello $user from the SOAP server";
}

1;

    
