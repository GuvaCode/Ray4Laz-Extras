program AnimateSprite;

uses
    SysUtils, mUnit;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
