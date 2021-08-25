program SpaceGame;

uses
    SysUtils, mUnit, GameClasses, gametypes;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
