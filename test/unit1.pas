unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_headers, ray_application, ray_sprites,  math;

type
TGame = class(TRayApplication)
  private
  protected
  public
    CamMain: TCamera2D;
    Engine: T2DEngine;
    Texture: TGameTexture;
    Ground: array of array of TRaySprite;
    Tree: array of TRaySprite;

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
begin
  Engine := T2DEngine.Create;
  Engine.Camera := camMain;
end;

procedure TGame.Update;
begin
end;

procedure TGame.Render;
begin
end;

procedure TGame.Shutdown;
begin
end;

end.

