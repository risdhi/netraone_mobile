<?php
namespace App\Models;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
class User extends Authenticatable {
 use Notifiable, HasApiTokens;
 protected $guarded=[];
 protected $hidden=['password','remember_token'];
 protected function casts():array{return ['password'=>'hashed','active'=>'boolean'];}
 public function company(){return $this->belongsTo(Company::class);}
 public function groups(){return $this->belongsToMany(Group::class);}
 public function isPlatform():bool{return $this->role==='platform_admin';}
 public function isMemberAdmin():bool{return $this->role==='member_admin';}
}
