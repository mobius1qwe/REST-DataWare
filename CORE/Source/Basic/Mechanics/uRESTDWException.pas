unit uRESTDWException;

{$I ..\..\Includes\uRESTDW.inc}

{ Maiores informações:
  https://github.com/OpenSourceCommunityBrasil/REST-DataWare/wiki/Informa%C3%A7%C3%B5es-extras-do-projeto
}

Interface

Uses
 SysUtils;

 Type
  eRESTDWException = Class(Exception)
 Public
  Constructor Create  (Const AMsg : String); Overload; Virtual;
 End;
 TClassIdException                      = Class Of eRESTDWException;
 eRESTDWSilentException                 = Class(eRESTDWException);
 eRESTDWConnClosedGracefully            = Class(eRESTDWSilentException);
 eRESTDWSocketHandleError               = Class(eRESTDWException);
 {$IFDEF RESTDWLINUX}
  eRESTDWNonBlockingNotSupported        = Class(eRESTDWException);
 {$ENDIF}
 eRESTDWMessageException                = Class(eRESTDWException);
 eRESTDWMessageCannotLoad               = Class(eRESTDWMessageException);
 eRESTDWPackageSizeTooBig               = Class(eRESTDWSocketHandleError);
 eRESTDWNotAllBytesSent                 = Class(eRESTDWSocketHandleError);
 eRESTDWCouldNotBindSocket              = Class(eRESTDWSocketHandleError);
 eRESTDWCanNotBindPortInRange           = Class(eRESTDWSocketHandleError);
 eRESTDWInvalidPortRange                = Class(eRESTDWSocketHandleError);
 eRESTDWCannotSetIPVersionWhenConnected = Class(eRESTDWSocketHandleError);
 eRESTDWReadTimeout                     = Class(eRESTDWException);
 eRESTDWReadLnWaitMaxAttemptsExceeded   = Class(eRESTDWException);
 eRESTDWFailedToRetreiveTimeZoneInfo    = Class(eRESTDWException);

Implementation

Constructor eRESTDWException.Create  (Const AMsg : String);
Begin
 Inherited Create(AMsg);
End;

End.
