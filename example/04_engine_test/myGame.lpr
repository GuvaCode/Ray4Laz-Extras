program myGame;

uses
    SysUtils, mnit, ray_SpriteEngine;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
