unit ray_application;

{$mode objfpc}{$H+}

interface

uses
  ray_headers;

type
{ TRayApplication }
TRayApplication = class (TObject)
  private
    FClearBgColor: TColor;
    procedure SetCaption(AValue: string);
  protected

  public
    // Create a new application
    constructor Create; virtual;
    // Free the application
    destructor Destroy; override;
    // Initializes the application
    procedure Init; virtual;
    // Shutdown the application
    procedure Shutdown; virtual;
    // Update the application
    procedure Update; virtual;
    // Render the application
    procedure Render; virtual;
    // Called when the device is resized
    procedure Resized; virtual;
    // Run the application
    procedure Run;
    // Terminate the application
    procedure Terminate;
    // Caption on window
    property Caption: string write SetCaption;
    property ClearBgColor: TColor read FClearBgColor write FClearBgColor;
  end;

implementation

procedure TRayApplication.SetCaption(AValue: string);
begin
  SetWindowTitle(PChar(AValue));
end;

{ TRayApplication }
constructor TRayApplication.Create;
begin
   InitWindow(800, 600, 'raylib [core] - basic window');
   SetWindowState(FLAG_VSYNC_HINT);
   FClearBgColor:= BLACK;
end;

destructor TRayApplication.Destroy;
begin
  inherited Destroy;
end;

procedure TRayApplication.Init;
begin

end;

procedure TRayApplication.Shutdown;
begin
  CloseWindow(); // Close window and OpenGL context
end;

procedure TRayApplication.Update;
begin

end;

procedure TRayApplication.Render;
begin


end;

procedure TRayApplication.Resized;
begin

end;

procedure TRayApplication.Run;
begin
  Init;
  Resized;

  while not WindowShouldClose() do
  begin
    Update;
    BeginDrawing();
    ClearBackground(FClearBgColor);
    Render;
    EndDrawing();
  end;
  Shutdown;

end;

procedure TRayApplication.Terminate;
begin

end;

end.
