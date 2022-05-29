// LOGIN

class UserNotFoundAuthException implements Exception {}
class WrongPasswordAuthException implements Exception {}

//REGISTER

class WeakPasswordAuthException implements Exception {}
class EmailAlreadyInUseAuthException implements Exception {}
class InvalidEmailAuthException implements Exception {}

//GENERIC

class GenericAuthException implements Exception {}
class UserNotLoggedInAuthException implements Exception {}

//