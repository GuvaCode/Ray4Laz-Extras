unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_headers, ray_application, ray_sprites,  math, classes;

type
TGame = class(TRayApplication)
  private
  protected
  public
    CamMain: TCamera2D;
    Engine: T2DEngine;
    Texture: TGameTexture;
    Ground: array of array of TRaySprite;
  //  Tree: array of TRaySprite;
    test:TRaySprite;
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
  end;

implementation

constructor TGame.Create;
begin
  inherited;

end;

procedure TGame.Init;
const
  MapSize = 2;
var a,b:integer;
begin
  Engine := T2DEngine.Create;
  camMain.zoom:=1;
  Engine.Camera := CamMain;
  Texture := TGameTexture.Create;
  Texture.LoadFromFile('bg.png', 256, 256);
  Texture.LoadFromFile('0.png', 38, 37);

  SetLength(Ground, MapSize + 1, MapSize + 1);

  for a := 0 to MapSize do
  begin
    for b := 0 to MapSize do
    begin
      Ground[a, b] := TRaySprite.Create(Engine, Texture);
      Ground[a, b].TextureName :='bg.png';
      Ground[a, b].X := a * 256;
      Ground[a, b].Y := b * 256;
      Ground[a, b].Z := 1;
      Ground[a, b].VisibleArea := Rect(-300, -300, 800, 600);
    end;
  end;


    test:=TRaySprite.Create(engine,Texture);
    test.TextureIndex:=1;
    test.X:=300;
    test.Y:=300;
    test.Z:=100;


  //Engine.Camera.offset.y:=0;
 // Engine.Camera.target.X:=0;
end;

procedure TGame.Update;
begin

  engine.Move(1);
end;

procedure TGame.Render;
begin
  ClearBackground(RED);
  BeginMode2D(camMain);
  engine.Draw;
  EndMode2D();
end;

procedure TGame.Shutdown;
begin
end;

end.

