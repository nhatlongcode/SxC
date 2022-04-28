namespace MadTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using System.Linq;
#if UNITY_EDITOR
    using UnityEditor;
#endif

    public class BoneRemap : MonoBehaviour
    {
        //Skin need to remap bone
        public SkinnedMeshRenderer skinnedMeshRenderer;
        //The root of charactor or gun (the best is "Bip001")
        public Transform meshRoot;
        //Name of bones
        public List<string> listBonePaths = new List<string>();

        public void RemapBones()
        {
            Transform[] bones = new Transform[listBonePaths.Count];
            int bindBoneCount = listBonePaths.Count;
            Transform[] listTrans = meshRoot.parent.GetComponentsInChildren<Transform>(true);


            for (int i = 0; i < bindBoneCount; i++)
            {
                Transform[] tempBoneTransform = (from x in listTrans
                                                 where (x.name == listBonePaths[i])
                                                 select x).ToArray();

                if (tempBoneTransform.Length > 0)
                {
                    bones[i] = tempBoneTransform[0];
                }
                else
                {
                    Debug.LogError("Can't find bone: " + listBonePaths[i] + " Model name: " + transform.parent.name);
                }
            }

            skinnedMeshRenderer.bones = bones;
            skinnedMeshRenderer.updateWhenOffscreen = true;
        }

        private void Start()
        {
            //Debug.Log(transform.root);
        }
    }

#if UNITY_EDITOR
    [CustomEditor(typeof(BoneRemap))]
    public class BoneRemapInspector : Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();
            GUILayout.Space(5);
            BoneRemap myTarget = (BoneRemap)target;
            if (GUILayout.Button("Remap bones, you must be on playing mode (test only)"))
            {
                myTarget.RemapBones();
            }
        }
    }
#endif

}