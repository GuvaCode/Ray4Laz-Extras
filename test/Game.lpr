program Game;

uses
    SysUtils, Unit1, Unit2;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
