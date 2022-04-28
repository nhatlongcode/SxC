namespace MadTools
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;


    [Serializable]
    public class GunSettings
    {
        public float damage;
        public float damageImpulse;
        public float roundsPerSecond;
        public int clipSize;
        public float reloadDuration;
        public float hitscanRadius;

        public float minCOF;
        public float maxCOF;
        public float shotCOFIncrease;
        public float COFDecreaseVel;
    }
}