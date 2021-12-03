unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, ray_timers, sysutils;

type

{ TGame }

TGame = class(TRayApplication)
  private
  protected
  public

    constructor Create; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure Resized; override;
   // procedure OnTimer;
end;

implementation
 var TIM:String;
 timers:zglPTimer;

 procedure OnTimer;
   begin
     Tim:= IntToStr(GetRandomValue(0,900))   ;
   end;

constructor TGame.Create;
begin
  //setup and initialization engine
  InitWindow(800, 600, 'raylib [Game Project]'); // Initialize window and OpenGL context 
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT); // Set window configuration state using flags
  //SetTargetFPS(120); // Set target FPS (maximum)
  ClearBackgroundColor:= BLACK; // Set background color (framebuffer clear color)
  timers:=timer_Add( @OnTimer, 24 );
end;

procedure TGame.Update;
begin
   timer_MainLoop;
end;

procedure TGame.Render;

begin
  DrawFPS(10, 10); // Draw current FPS
  DrawText(PChar(Tim),10,50,20,BLUE);
end;

procedure TGame.Resized;
begin
end;


procedure TGame.Shutdown;
begin
  timer_Del(timers);
end;

end.

