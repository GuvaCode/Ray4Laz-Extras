unit mUnit;

{$mode objfpc}{$H+} 

interface

uses
  cmem, ray_header, ray_application, ray_sprite_engine, GameClasses, ray_math_ex;

type

{ TGame }

TGame = class(TRayApplication)
  private
  protected
  public
    constructor Create; override;
    procedure Init; override;
    procedure Update; override;
    procedure Render; override;
    procedure Shutdown; override;
    procedure LoadingTexture(FileName: string);
    procedure LoadMap(FileName: string);
  end;

implementation
uses gametypes , fgl, SysUtils, Classes;

constructor TGame.Create;
var FileSearchRec: TSearchRec;
     i:integer;
     Rn:integer;
begin
   InitWindow(1024, 768, 'raylib [core] - basic window');
  SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT);

  SetTargetFPS(60); // set FPS
   ClearBgColor:=Black;
  //Greate FPGMap for image list
  GameImages:= specialize TFPGMap<string, TTexture>.Create;

  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.VisibleWidth := 1800;
  SpriteEngine.VisibleHeight := 1600;

  //loadimages
  if FindFirst(ExtractFilePath(ParamStr(0)) + 'spacegame/Gfx/' + '*.png', faAnyfile, FileSearchRec) = 0 then
    repeat
      LoadingTexture('spacegame/Gfx/' + FileSearchRec.Name);
    until FindNext(FileSearchRec) <> 0;
  LoadingTexture('spacegame/Gfx/Space.jpg');

  // create asteroids
  for  I := 0 to 500 do
    with TAsteroids.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      ImageName := 'Roids' + IntToStr(Random(3));
      PosX := Random(8000) - 2500;
      PosY := Random(8000) - 2500;
      Z := 4800;
      DoCenter := True;

      if ImageName = 'Roids0' then
      begin
        SetPattern(64, 64);
        SetAnim(ImageName, 0, PatternCount, 8, True, True, MirrorNormal);
      end;
      if ImageName = 'Roids1' then
      begin
        SetPattern(96, 96);
        SetAnim(ImageName, 0, PatternCount, 11, True, True, MirrorNormal);
      end;
      if ImageName = 'Roids2' then
      begin
        SetPattern(128, 128);
        SetAnim(ImageName, 0, PatternCount, 9, True, True, MirrorNormal);
      end;
      rn:=Random(1);
      if rn=0 then  MoveSpeed :=0.15;
      if rn=1 then  MoveSpeed :=-0.5;
      DoCenter := True;
      Range := 150 + Random(200);
      Step := (Random(1512));
      Seed := 50 + Random(100);
      Life := 6;
      ScaleX := 1;
      ScaleY := 1;
      Collisioned := True;
      if ImageName = 'Roids0' then
        CollideRadius := 32;
      if ImageName = 'Roids1' then
        CollideRadius := 48;
      if ImageName = 'Roids2' then
        CollideRadius := 50;
      Width := PatternWidth;
      Height := PatternHeight;
    end;

  // create player's ship
  PlayerShip := TPlayerShip.Create(SpriteEngine);
  with PlayerShip do
  begin
    ImageLib := GameImages;
    ImageName := 'PlayerShip';
    SetPattern(64, 64);
    Width := PatternWidth;
    Height := PatternHeight;

 //   ScaleX := 1.2;
  //  ScaleY := 1.2;
    DoCenter := True;
    //DrawMode := 1;

    Acceleration := 0.02;
    Decceleration := 0.02;
    MinSpeed := 0;
    Maxspeed := 4.5;
    Z := 5000;
    Collisioned := True;
    CollideRadius := 25;
  end;


    // create enemys
  for  I := 0 to 400 do
  begin
    with TEnemy.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      Kind := TEnemyKind(Random(4));
      //DrawMode := 1;
      X := Random(8000) - 2500;
      Y := Random(8000) - 2500;
      Z := 10000;
      Collisioned := True;
      MoveSpeed := 1 + (Random(4) * 0.5);
      RotateSpeed := 0.5 + (Random(4) * 0.4);
      Life := 4;
      case Kind of
        Ship:
          begin
            ImageName := 'Ship' + IntToStr(Random(2));
            SetPattern(128, 128);
            CollideRadius := 40;
            ScaleX := 0.7;
            ScaleY := 0.8;
          end;
        SquareShip:
          begin
            ImageName := 'SquareShip' + IntToStr(Random(2));
            CollideRadius := 30;
            LookAt := True;
            if ImageName = 'SquareShip0' then
              SetPattern(60, 62)
            else
              SetPattern(72, 62);

          end;
        AnimShip:
          begin
            ImageName := 'AnimShip' + IntToStr(Random(2));
            CollideRadius := 25;
            // ScaleX := 1.1;
            // ScaleY := 1.1;

            if ImageName = 'AnimShip1' then
            begin
              SetPattern(64, 64);
              SetAnim(ImageName, 0, 8, 0.2, True, False, MirrorNormal);
            end;
            if ImageName = 'AnimShip0' then
            begin
              SetPattern(48, 62);
              SetAnim(ImageName, 0, 4, 0.08, True, False, MirrorNormal);
            end;
          end;
        Mine:
          begin
            ImageName := 'Mine0';
            SetPattern(64, 64);
            CollideRadius := 16;
            RotateSpeed := 0.04;
          end;
      end;
      TempMoveSpeed := MoveSpeed;
      Width := PatternWidth;
      Height := PatternHeight;
    end;
  end;


    LoadMap('Level1.map');
  CreateMap(500, 500);


end;

procedure TGame.Init;
begin
end;

procedure TGame.Update;
begin


  if IsMouseButtonPressed(MOUSE_RIGHT_BUTTON) then
  begin
  //  CursorX := X;
  //  CursorY := Y;
    PlayerShip.DoAccelerate := True;
    PlayerShip.DoDeccelerate := False;
  end;

  if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) and (PlayerShip.ImageName = 'PlayerShip') then
  begin
    //PlaySound('Shoot.wav');
 //   PlayerShip.Angle:=Round(PlayerShip.Angle);
    PlayerShip.Bullet := TPlayerBullet.Create(SpriteEngine);
    with PlayerShip.Bullet do
    begin

      ImageLib := GameImages;
      ImageName := 'bb';
      SetPattern(24, 36);
      Width := PatternWidth;
      Height := PatternHeight;
      ScaleX := 1;
      ScaleY := 1;
     // DrawMode := 1;  ///////////////////////////////////

      BlendingEffect := TBlendingEffect.Additive;
      DoCenter := True;
      MoveSpeed := 9;
      Angle:=90;//PlayerShip.Angle;

      X := PlayerShip.X;
      Y := PlayerShip.Y;


      Z := 11000;
      Collisioned := True;
      CollideRadius := 10;

    end;
  end;

  if IsMouseButtonReleased(MOUSE_LEFT_BUTTON) then
  begin
   PlayerShip.DoAccelerate := False;
   PlayerShip.DoDeccelerate := True;
  end;

 //
  // PlayerShip.Angle:=PlayerShip.Angle+1;

  //Angle := m_Angle(Trunc(GetMouseX) - 512, Trunc(GetMouseY) - 384,Self.X - Self.PatternWidth  ,Self.Y - Self.PatternHeight);



 ///Random(360);



  SpriteEngine.Move(1); // update sprite engine on frame time
end;

procedure TGame.Render;
begin
   SpriteEngine.Draw;

  DrawText(PChar(IntToStr(GetFPS)+' FPS'),10,10,10,BLACK);
  DrawText(PChar(IntToStr(GetMouseX)+' ------ '+ IntToStr(GetMouseY)),50,10,10,Red);
  DrawText(PChar(FloatToStr(PlayerShip.Angle)),10,30,10,Red);

end;

procedure TGame.Shutdown;
begin
end;

procedure TGame.LoadingTexture(FileName: string);
var  Texture:TTexture;
begin
  Texture:=LoadTexture(Pchar(FileName));
  GameImages.Add(ChangeFileExt(ExtractFileName(FileName), ''), Texture);

end;

procedure TGame.LoadMap(FileName: string);
var
  Fs: TFileStream;
begin
  Fs := TFileStream.Create(FileName, fmOpenRead);
  Fs.ReadBuffer(FileSize_, SizeOf(FileSize_));
  SetLength(MapData, FileSize_);
  Fs.ReadBuffer(MapData[0], SizeOf(TMapRec) * FileSize_);
  Fs.Destroy;
end;

end.

