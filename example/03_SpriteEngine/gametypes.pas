unit gametypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, GameClasses, ray_sprite_engine_ex, fgl, ray_header;

var
  PlayerShip: TPlayerShip;
  Score:integer;
  SpriteEngine: TSpriteEngine;
  FileSize_: Integer;
  GameImages: specialize TFPGMap<string, TTexture>; //For image
  MapData: array of TMapRec;

  procedure CreateBonus(BonusName: string; PosX, PosY: Single);
  procedure CreateSpark(PosX, PosY: Single);
  procedure CreateMap(OffsetX, OffsetY: Integer);


implementation

procedure CreateBonus(BonusName: string; PosX, PosY: Single);
begin
  if (Random(3) = 1) or (Random(3) = 2) then
  begin
    with TBonus.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      ImageName := BonusName;
      SetPattern(32, 32);
      Width := PatternWidth;
      Height := PatternHeight;
      MoveSpeed := 0.251;
      PX := PosX - 50;
      PY := PosY - 100;
      Z := 12000;
      ScaleX := 1.5;
      ScaleY := 1.5;
      DoCenter := True;
      Collisioned := True;
      CollideRadius := 24;
      SetAnim(ImageName, 0, PatternCount, 0.25, True); //paterncount-1????
    end;
  end;
end;

procedure CreateSpark(PosX, PosY: Single);
var
  I, Pattern: Integer;
const
  RandNumber: array[0..1] of string = ('5', '9');
begin
  Pattern :=0; //todo  see awterwarp //RandomFrom(RandNumber).ToInteger;
  for I := 0 to 128 do
  begin
    with TSpark.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      ImageName := 'Particles';
      SetPattern(32, 32);
      Width := PatternWidth;
      Height := PatternHeight;
      // todoBlendingEffect := TBlendingEffect.Add;
      X := PosX + -Random(30);
      Y := PosY + Random(30);
      Z := 12000;
      PatternIndex := Pattern;
      ScaleX := 1.2;
      ScaleY := 1.2;
      Red := Random(250);
      Green := Random(250);
      Blue := Random(250);
      Acceleration := 0.02;
      MinSpeed := 0.8;
      Maxspeed := -(0.4 + Random(2));
      Direction := I * 2;
    end;
  end;

end;

procedure CreateMap(OffsetX, OffsetY: Integer);
var
  I: Integer;
begin
  for I := 0 to FileSize_ - 1 do
  begin
    if LeftStr(MapData[I].ImageName, 4) = 'Tile' then
    begin
      with TSprite.Create(SpriteEngine) do
      begin
        ImageLib := GameImages;
        ImageName := LowerCase(MapData[I].ImageName);
        Width := ImageWidth;
        Height := ImageHeight;
        X := MapData[I].X + OffsetX - 2500;
        Y := MapData[I].Y + OffsetY - 2500;
        Z := MapData[I].Z;
        Moved := False;
      end;
    end;
    //
    if LeftStr(MapData[I].ImageName, 4) = 'Fort' then
    begin
      with TFort.Create(SpriteEngine) do
      begin
        ImageLib := GameImages;
        ImageName := LowerCase(MapData[I].ImageName);
        SetPattern(44, 77);
       // DrawMode := 1;
        DoCenter := True;
        Width := PatternWidth;
        Height := PatternHeight;
        X := MapData[I].X + OffsetX - 2500 + 22;
        Y := MapData[I].Y + OffsetY - 2500 + 40;
        Z := MapData[I].Z;
        Collisioned := True;
        CollideRadius := 24;
        Life := 5;
      end;
    end;
  end;
end;


end.

