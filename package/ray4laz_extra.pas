{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ray4laz_extra;

{$warn 5023 off : no warning about unused units}
interface

uses
  ray4lazEx_desc, ray4lazex_desc2d, ray_application, ray_model, 
  ray_sprite_engine, ray_timers, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ray4lazEx_desc', @ray4lazEx_desc.Register);
  RegisterUnit('ray4lazex_desc2d', @ray4lazex_desc2d.Register);
end;

initialization
  RegisterPackage('ray4laz_extra', @Register);
end.
