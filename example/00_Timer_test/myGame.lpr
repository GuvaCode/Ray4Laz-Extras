program myGame;

uses
    SysUtils, Unit1, ray_timers;


var Game: TGame;

begin
  Game:= TGame.Create;
  Game.Run;
  Game.Free;
end.
