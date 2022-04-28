namespace MadTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class GunExportConfig : ScriptableObject
    {
        public string ResourceFolder = "Assets/MadProject/Resources/3D/Weapons/";
        public string DataRootFolder = "Assets/MadProject/Data/3D/Guns/";
        public string GunTestScene = "Assets/MadTools/Scenes/ScenesPreviewGuns/GunSetUpGun.unity";
        [HideInInspector]
        public AnimationExportConfig AnimationExportConfig = new AnimationExportConfig();
        [HideInInspector]
        public GunMeshExportConfig GunMeshExportConfig = new GunMeshExportConfig();
    }

    public class AnimationExportConfig
    {
        public List<AnimPrefix> AnimPrefixes = new List<AnimPrefix> { new AnimPrefix("Anim_GunFPS_", "Gun"),
                                                                  new AnimPrefix("Anim_Hand_", "Hand"),
                                                                  new AnimPrefix("Anim_Cam_", "Cam")};

        public List<string> Action = new List<string>
        {
            "None",
            "HandIdle", "HandIdleNonLoop", "HandRaiseUp", "HandReload", "HandShoot", "HandTookDown", "HandShootBegin", "HandShootEnd", "HandZoomIn", "HandZoomOut",
            "GunIdle", "GunIdleNonLoop", "GunRaiseUp", "GunReload", "GunShoot", "GunTookDown", "GunShootBegin", "GunShootEnd", "GunZoomIn", "GunZoomOut",
            "CamIdle", "CamShoot", "CamShootBegin", "CamShootEnd",
            "HandReloadRaiseUp", "HandReloadBullet", "HandReloadRaiseDown", "HandLoadBullet",
            "GunReloadRaiseUp", "GunReloadBullet", "GunReloadRaiseDown", "GunLoadBullet",
            "HandRun", "GunRun", 

            "GunIdlePreview",
            "GunWalkStop",
            "GunAimingUp", "GunAiming", "GunAimingDown",
            "GunCheer",
            "GunKneel",
            "GunLie",
            "GunBeHitPvPUp","GunBeHitPvP","GunBeHitPvPDown",
            "GunReloadPvP",
            "GunDeadPvP",
            "GunShootPvP",
            "GunShootPvPUp",
            "GunShootPvPDown"
        };
    }

    public class GunMeshExportConfig
    {
        public List<string> GunAttachPosition = new List<string> { "Pos_MainMesh", "Pos_Body", "Pos_Mag", "Pos_Light", "Pos_Muzzle", "Pos_Scope",
            "Pos_LightMuzzle", "Pos_Stock", "Pos_Rocket", "Pos_Bullet",
            "Pos_Bullet_01", "Pos_Bullet_02", "Pos_Bullet_03", "Pos_Bullet_04", "Pos_Bullet_05", "Pos_Bullet_06", "Pos_BulletCluster",
            "Pos_Others"};

        public int GetAttachIDByName(string name)
        {
            for (int i = 0, n = GunAttachPosition.Count; i < n; i++)
            {
                if (GunAttachPosition[i] == name)
                {
                    return i;
                }
            }

            return -1;
        }
    }

    public class AnimPrefix
    {
        public string FilePrefix;
        public string ActionPrefix;

        public AnimPrefix(string filePrefix, string actionPrefix)
        {
            this.FilePrefix = filePrefix;
            this.ActionPrefix = actionPrefix;
        }
    }
}