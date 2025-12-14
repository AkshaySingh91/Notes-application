// login exceptions
class UserNotFoundException implements Exception {}

class WrongPasswordException implements Exception {}

// Register exceptions
class InvalidEmailException implements Exception {}

class WeakPasswordException implements Exception {}

class EmailAlreadyInUserException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}
