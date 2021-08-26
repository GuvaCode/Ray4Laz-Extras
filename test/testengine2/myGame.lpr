program myGame;

uses
    SysUtils, Unit1;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
