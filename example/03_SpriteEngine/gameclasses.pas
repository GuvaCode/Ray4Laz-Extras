unit GameClasses;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ray_sprite_engine, ray_header;


type
  TEnemyKind = (Ship, SquareShip, AnimShip, Mine);

  TMapRec = record
    X, Y, Z: Integer;
    ImageName: string[50];
  end;

  { TBullet }

  TBullet = class(TAnimatedSprite)
  private
    DestAngle: Single;
    FMoveSpeed: Integer;
    FCounter: Integer;
  public
    constructor Create(const AParent: TSprite); override;
    procedure DoMove(const MoveCount: Single); override;
    property MoveSpeed: Integer read FMoveSpeed write FMoveSpeed;
  end;

  { TPlayerBullet }

  TPlayerBullet = class(TAnimatedSprite)
  private
    FDestX, FDestY: Integer;
    FCounter: Integer;
    FMoveSpeed: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    procedure DoCollision(const Sprite: TSprite); override;
    property DestX: Integer read FDestX write FDestX;
    property DestY: Integer read FDestY write FDestY;
    property MoveSpeed: Integer read FMoveSpeed write FMoveSpeed;
  end;

  { TEnemy }

  TEnemy = class(TAnimatedSprite)
  private
    FMoveSpeed: Single;
    FTempMoveSpeed: Single;
    FRotateSpeed: Single;
    FDestX, FDestY: Integer;
    FDestAngle: Integer;
    FLookAt: Boolean;
    FKind: TEnemyKind;
    FLife: Integer;
    FBullet: TBullet;
  public
    function InOffScreen: Boolean;
    procedure DoMove(const MoveCount: Single); override;
    property Kind: TEnemyKind read FKind write FKind;
    property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
    property TempMoveSpeed: Single read FTempMoveSpeed write FTempMoveSpeed;
    property RotateSpeed: Single read FRotateSpeed write FRotateSpeed;
    property DestX: Integer read FDestX write FDestX;
    property DestY: Integer read FDestY write FDestY;
    property DestAngle: Integer read FDestAngle write FDestAngle;
    property LookAt: Boolean read FLookAt write FLookAt;
    property Life: Integer read FLife write FLife;
    property Bullet: TBullet read FBullet write FBullet;
  end;

  { TAsteroids }

  TAsteroids = class(TAnimatedSprite)
  private
    FStep: Single;
    FMoveSpeed: Single;
    FRange: Single;
    FSeed: Integer;
    FPosX: Integer;
    FPosY: Integer;
    FLife: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
    property Step: Single read FStep write FStep;
    property Seed: Integer read FSeed write FSeed;
    property Range: Single read FRange write FRange;
    property PosX: Integer read FPosX write FPosX;
    property PosY: Integer read FPosY write FPosY;
    property Life: Integer read FLife write FLife;
  end;

  { TFort }
  TFort = class(TAnimatedSprite)
  private
    FLife: Integer;
    FBullet: TBullet;
  public
    procedure DoMove(const MoveCount: Single); override;
    property Bullet: TBullet read FBullet write FBullet;
    property Life: Integer read FLife write FLife;
  end;

  { TPlayerShip }
  TPlayerShip = class(TPlayerSprite)
  private
    FDoAccelerate: Boolean;
    FDoDeccelerate: Boolean;
    FLife: Single;
    FBullet: TPlayerBullet;
    FReady: Boolean;
    FReadyTime: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    procedure DoCollision(const Sprite: TSprite); override;
    property DoAccelerate: Boolean read FDoAccelerate write FDoAccelerate;
    property DoDeccelerate: Boolean read FDoDeccelerate write FDoDeccelerate;
    property Bullet: TPlayerBullet read FBullet write FBullet;
    property Life: Single read FLife write FLife;
  end;

  { TTail }
  TTail = class(TPlayerSprite)
  private
    FCounter: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    property Counter: Integer read FCounter write FCounter;
  end;

  { TExplosion }
  TExplosion = class(TPlayerSprite)
  public
    procedure DoMove(const MoveCount: Single); override;
  end;

  { TSpark }

  TSpark = class(TPlayerSprite)
  public
    procedure DoMove(const MoveCount: Single); override;
  end;

  { TBonus }

  TBonus = class(TAnimatedSprite)
  private
    FPX, FPY: Single;
    FStep: Single;
    FMoveSpeed: Single;
  public
    procedure DoMove(const MoveCount: Single); override;
    property PX: Single read FPX write FPX;
    property PY: Single read FPY write FPY;
    property Step: Single read FStep write FStep;
    property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
  end;


implementation
uses gametypes, ray_math_ex;

{ TAsteroids }
procedure TAsteroids.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
  X := PosX + Cos(Step / (30)) * Range - (Sin(Step / (20)) * Range);
  Y := PosY + Sin(Step / (30 + Seed)) * Range + (Cos(Step / (20)) * Range);
  Step := Step + MoveSpeed;
  if ImageName = 'Roids2' then
    Angle := Angle + 0.02;
  if ImageName = 'Roids0' then
    CollidePos := Point(Round(X) + 32, Round(Y) + 32);
  if ImageName = 'Roids1' then
    CollidePos := Point(Round(X) + 30, Round(Y) + 30);
  if ImageName = 'Roids2' then
    CollidePos := Point(Round(X) + 34, Round(Y) + 34);
  BlendingEffect := TBlendingEffect.Undefined;
end;

{ TPlayerBullet }
procedure TPlayerBullet.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
 // Angle:=PlayerShip.Angle;
///  TowardToAngle(Trunc(Angle / 40), MoveSpeed, True);
  Self.RotateToAngle(0,10,MoveSpeed);
 { CollidePos := Point(Round(X) + 24, Round(Y) + 38);
  Inc(FCounter);

  if FCounter > 180 then
    Dead;
  if Trunc(AnimPos) >= 11 then
    Dead;
  Collision;  }

end;

procedure TPlayerBullet.DoCollision(const Sprite: TSprite);
var
  I: Integer;
begin
  if Sprite is TAsteroids then
  begin
    //PlaySound('Hit.wav');
    Collisioned := False;
    MoveSpeed := 0;
    SetPattern(64, 64);
    SetAnim('Explosions', 0, 12, 0.3, False);

    { todo if Trunc(AnimPos) < 1 then
      TAsteroids(Sprite).BlendingEffect := TBlendingEffect.Shadow;}

    TAsteroids(Sprite).Life := TAsteroids(Sprite).Life - 1;
    if (TAsteroids(Sprite).Life <= 0) then
    begin
     // PlaySound('Explode.wav');
      TAsteroids(Sprite).MoveSpeed := 0;
      for I := 0 to 128 do
        with TExplosion.Create(SpriteEngine) do
        begin
          ImageLib := GameImages;
          ImageName := 'Particles';
          SetPattern(32, 32);
          Width := PatternWidth;
          Height := PatternHeight;
          BlendingEffect := TBlendingEffect.Additive;
          X := TAsteroids(Sprite).X + -Random(60);
          Y := TAsteroids(Sprite).Y - Random(60);
          Z := 4850;
          PatternIndex := 7;
          ScaleX := 3;
          ScaleY := 3;
          Red := 255;
          Green := 100;
          Blue := 101;
          Acceleration := 0.0252;
          MinSpeed := 1;
          Maxspeed := -(0.31 + Random(2));
          Direction := I * 2;
        end;
      CreateBonus('Money', TAsteroids(Sprite).X, TAsteroids(Sprite).Y);
      TAsteroids(Sprite).Dead;
    end;
  end;
  //
  if Sprite is TEnemy then
  begin
   /// PlaySound('Hit.wav');
    Collisioned := False;
    MoveSpeed := 0;
    SetPattern(64, 64);
    SetAnim('Explosion3', 0, 12, 0.3, False);
    if Trunc(AnimPos) < 1 then
      TEnemy(Sprite).BlendingEffect := TBlendingEffect.Additive;
    TEnemy(Sprite).Life := TEnemy(Sprite).Life - 1;
    if TEnemy(Sprite).Life <= 0 then
    begin
      TEnemy(Sprite).MoveSpeed := 0;
      TEnemy(Sprite).RotateSpeed := 0;
      TEnemy(Sprite).DestAngle := 0;
      TEnemy(Sprite).LookAt := False;
      TEnemy(Sprite).BlendingEffect := TBlendingEffect.Additive;
      TEnemy(Sprite).ScaleX := 3;
      TEnemy(Sprite).ScaleY := 3;
      TEnemy(Sprite).SetPattern(64, 64);
      TEnemy(Sprite).SetAnim('Explosion2', 0, 16, 0.15, False);
      CreateBonus('Bonus' + IntToStr(Random(3)), X, Y);
    end;
  end;
  //
  if Sprite is TFort then
  begin
   // PlaySound('Hit.wav');
    Collisioned := False;
    MoveSpeed := 0;
    SetPattern(64, 64);
    SetAnim('Explosion3', 0, 12, 0.3, False);
    if Trunc(AnimPos) < 3 then
      TFort(Sprite).SetColor(255, 0, 0);
    TFort(Sprite).Life := TFort(Sprite).Life - 1;
    if TFort(Sprite).Life <= 0 then
    begin
      TFort(Sprite).BlendingEffect := TBlendingEffect.Additive;
      TFort(Sprite).ScaleX := 3;
      TFort(Sprite).ScaleY := 3;
      TFort(Sprite).SetPattern(64, 64);
      TFort(Sprite).SetAnim('Explosion2', 0, 16, 0.15, False);
    end;
  end;
end;

{ TEnemy }
function TEnemy.InOffScreen: Boolean;
begin
    if (X > Engine.WorldX - 50) and (Y > Engine.WorldY - 50) and (X < Engine.WorldX + 1124) and (Y <
    Engine.WorldY + 778) then
    Result := True
  else
    Result := False;
end;

procedure TEnemy.DoMove(const MoveCount: Single);
begin
  { todo if (Life >= 1) and (ImageName <> 'Explosion2') then
    BlendingEffect := TBlendingEffect.Normal;}

  if (InOffScreen) and (ImageName <> 'Explosion2') then
    MoveSpeed := TempMoveSpeed;

  if (Life <= 0) or (not InOffScreen) then
    MoveSpeed := 0;
  if Trunc(AnimPos) >= 15 then
    Dead;
  if (Trunc(AnimPos) >= 1) and (ImageName = 'Explosion2') then
    Collisioned := False;

  case Kind of
    Ship:
      begin
        CollidePos := Point(Round(X) + 64, Round(Y) + 64);
        case Random(100) of
          40..43:
            begin
              DestAngle := Random(255);
            end;
          51..52:
            begin
              DestAngle := Trunc(Angle256(Trunc(PlayerShip.X) - Trunc(Self.X), Trunc(PlayerShip.Y)
                - Trunc(Self.Y)));
            end;
        end;
        RotateToAngle(DestAngle, RotateSpeed, MoveSpeed);
      end;

    SquareShip:
      begin
        CollidePos := Point(Round(X) + 30, Round(Y) + 30);
        case Random(100) of
          40..45:
            begin
              DestX := Random(8000);
              DestY := Random(6000)
            end;
          51..52:
            begin
              DestX := Trunc(PlayerShip.X);
              DestY := Trunc(PlayerShip.Y);

            end;
        end;
        CircleToPos(DestX, DestY, Trunc(PlayerShip.X), Trunc(PlayerShip.Y),
          RotateSpeed, MoveSpeed, LookAt);
      end;

    AnimShip:
      begin
        CollidePos := Point(Round(X) + 20, Round(Y) + 20);
        case Random(100) of
          40..45:
            begin
              DestX := Random(8000);
              DestY := Random(6000)
            end;
          51..54:
            begin
              DestX := Trunc(PlayerShip.X);
              DestY := Trunc(PlayerShip.Y);
            end;
        end;
        RotateToPos(DestX, DestY, RotateSpeed, MoveSpeed);
      end;

    Mine:
      begin
        CollidePos := Point(Round(X) + 32, Round(Y) + 32);
        case Random(300) of
          150:
            begin
              DestX := Trunc(PlayerShip.X);
              DestY := Trunc(PlayerShip.Y);
            end;
          200..202:
            begin
              DestX := Random(8000);
              DestY := Random(8000);
            end;
        end;
        Angle := Angle + RotateSpeed;
        TowardToPos(DestX, DestY, MoveSpeed, False);
      end;

  end;

  // enemy shoot bullet
  if (Kind = Ship) or (Kind = SquareShip) then
  begin
    if InOffScreen then
    begin
      if Random(100) = 50 then
      begin
        Bullet := TBullet.Create(SpriteEngine);
        Bullet.ImageName := 'bulletr';
        Bullet.MoveSpeed := 5;
        Bullet.X := Self.X + 1;
        Bullet.Y := Self.Y;
        Bullet.DestAngle := Angle * 40;
      end;
    end;
  end;
  inherited;
end;

{ TBullet }
constructor TBullet.Create(const AParent: TSprite);
begin
  inherited Create(AParent);
  ImageLib := GameImages;
  SetPattern(40, 40);
  // todo BlendingEffect := TBlendingEffect.Add;
  Z := 4000;
  FCounter := 0;
 //todo DrawMode := 1;
  Collisioned := True;
  if ImageName = 'bulletr' then
    CollideRadius := 15;
  if ImageName = 'BulletS' then
    CollideRadius := 12;
end;

procedure TBullet.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
    CollidePos := Point(Round(X) + 20, Round(Y) + 20);
  TowardToAngle(Trunc(DestAngle), MoveSpeed, True);
  Inc(FCounter);
  if (Trunc(AnimPos) >= 15) and (ImageName = 'Explosion3') then
    Dead;
  if FCounter > 250 then
    Dead;
end;

{ TFort }
procedure TFort.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
   SetColor(255, 255, 255);
  if ImageName = 'fort' then
    LookAt(Trunc(PlayerShip.X), Trunc(PlayerShip.Y));
  CollidePos := Point(Round(X) + 22, Round(Y) + 36);
  if Trunc(AnimPos) >= 15 then
    Dead;
  if (Trunc(AnimPos) >= 1) and (ImageName = 'Explosion2') then
    Collisioned := False;

  if Random(150) = 50 then
  begin
    if (X > Engine.WorldX + 0) and (Y > Engine.WorldY + 0) and (X < Engine.WorldX + 800) and (Y <
      Engine.WorldY + 600) then
    begin
      Bullet := TBullet.Create(SpriteEngine);
      Bullet.ImageName := 'BulletS';
      Bullet.Width := 40;
      Bullet.Height := 40;
      // todo Bullet.BlendingEffect := TBlendingEffect.Add;
      Bullet.MoveSpeed := 4;
      Bullet.Z := 4000;
      Bullet.FCounter := 0;
      Bullet.X := Self.X + 5;
      Bullet.Y := Self.Y;
     // todo  Bullet.DrawMode := 1;
      Bullet.DestAngle := Angle * 40;
    end;
  end;
end;

{ TPlayerShip }
procedure TPlayerShip.DoMove(const MoveCount: Single);
 begin
    inherited;
    SetColor(255, 255, 255);
    CollidePos := Point(Round(X) + 20, Round(Y) + 20);
    Collision;
    if DoAccelerate then
      Accelerate;
    if DoDeccelerate then
      Deccelerate;
    if ImageName = 'PlayerShip' then
    begin
      UpdatePos(1);
     // if Angle < 0 then Angle:=0;
     // if Angle> 360 then angle:=0;
      LookAt(GetMouseX, GetMouseY);
    // Angle:=Self.Angle;
   //  Angle := Angle256(Trunc(GetMouseX) - 512, Trunc(GetMouseY) - 384) ;



   ///  Direction := Trunc(Angle256(GetMouseX - 512, GetMouseY - 384));
   //  Angle360:= Round(Angle256(GetMouseX - 512, GetMouseY - 384) * 0.2);
   // Angle:=Angle256(GetMouseX - 512, GetMouseY - 384) * 0.2;
     //Round(m_Angle(X-PlayerShip.PatternWidth/2,Y-PlayerShip.PatternHeight/2,GetMouseX,GetMouseY));

    // Angle360:=

     // Direction:=Trunc(m_Angle(GetMouseX,GetMouseY,Self.X,Self.Y));
       //   Angle := Angle256(Trunc(GetMouseX) - 360, Trunc(GetMouseY));
    //   Direction := Trunc(Angle256(GetMouseX - 512, GetMouseX - 384));
    end;
    if (Trunc(AnimPos) >= 32) and (ImageName = 'Explode') then
    begin
      ImageName := 'PlayerShip';
      BlendingEffect := TBlendingEffect.Undefined;//normal?????
      ScaleX := 1.0;
      ScaleY := 1.0;
    end;
    if FReady then
      Inc(FReadyTime);
    if FReadyTime = 350 then
    begin
      FReady := False;
      Collisioned := True;
    end;
    Engine.WorldX := X - 512;
    Engine.WorldY := Y - 384;
  end;

procedure TPlayerShip.DoCollision(const Sprite: TSprite);
var
  I: Integer;
begin
  if Sprite is TBonus then
  begin
   // PlaySound('GetBonus.wav');
    if TBonus(Sprite).ImageName = 'Bonus0' then  Inc(Score, 100);
    if TBonus(Sprite).ImageName = 'Bonus1' then Inc(Score, 200);
    if TBonus(Sprite).ImageName = 'Bonus2' then Inc(Score, 300);
    if TBonus(Sprite).ImageName = 'Money' then Inc(Score, 500);
    CreateSpark(TBonus(Sprite).X, TBonus(Sprite).Y);
    TBonus(Sprite).Dead;
  end;
  if Sprite is TBullet then
  begin
   // PlaySound('Hit.wav');
    PlayerShip.Life := PlayerShip.Life - 0.25;
    Self.SetColor(255, 0, 0);
    TBullet(Sprite).Collisioned := False;
    TBullet(Sprite).MoveSpeed := 0;
    TBullet(Sprite).SetPattern(64, 64);
    TBullet(Sprite).SetAnim('Explosion3', 0, 12, 0.3, False,True,MirrorNormal);
    TBullet(Sprite).Z := 10000;
  end;

  if (Sprite is TAsteroids) or (Sprite is TEnemy) then
  begin
   // PlaySound('Hit.wav');
    FReady := True;
    FReadyTime := 0;
    PlayerShip.Life := PlayerShip.Life - 0.25;
    AnimPos := 0;
    SetPattern(64, 64);
    SetAnim('Explode', 0, 40, 25, False,True, MirrorNormal);
    BlendingEffect:=TBlendingEffect.Additive;
    Collisioned := False;
    ScaleX := 1.5;
    ScaleY := 1.5;
  end;
end;

{ TTail }
procedure TTail.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
  Alpha := Alpha - 6;
  if PlayerShip.Speed < 1.1 then
  begin
    ScaleX := ScaleX + 0.01;
    ScaleY := ScaleY + 0.01;
  end
  else
  begin
    ScaleX := ScaleX + 0.025;
    ScaleY := ScaleY + 0.025;
  end;
  Angle := Angle + 0.125;
  UpdatePos(1);
  Accelerate;
  Inc(FCounter);
  if FCounter > 25 then
    Dead;
end;

{ TExplosion }
procedure TExplosion.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
  Accelerate;
  UpdatePos(1);
  Alpha := Alpha - 1;
  if Alpha <= 1 then Dead;
end;

{ TSpark }
procedure TSpark.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
  Accelerate;
  UpdatePos(1);
  Alpha := Alpha - 1;
  if Alpha < 1 then Dead;
end;

{ TBonus }
procedure TBonus.DoMove(const MoveCount: Single);
begin
  inherited DoMove(MoveCount);
  CollidePos := Point(Round(X) + 24, Round(Y) + 24);
  X := PX + Cos(Step / (30)) * 60 - (Sin(Step / (20)) * 150);
  Y := PY + Sin(Step / (90)) * 130 + (Cos(Step / (20)) * 110);
  Step := Step + MoveSpeed;
end;

end.

