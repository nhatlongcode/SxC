namespace MadTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class PartMaterialPath : MonoBehaviour
    {
        public List<string> matPaths = new List<string>();

        // Start is called before the first frame update
        void Start()
        {
            List<Material> mats = new List<Material>();

            for (int i = 0; i < matPaths.Count; i++)
            {
                mats.Add(Resources.Load("Weapon/AR160/Material/" + matPaths[i]) as Material);
            }

            GetComponent<MeshRenderer>().sharedMaterials = mats.ToArray();
            GetComponent<MeshRenderer>().materials = mats.ToArray();
        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}   