unit Unit1;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, math;

type
TGame = class(TRayApplication)
  private
  protected
  public
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

