namespace MadTools
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;
#endif

    public class GunParts : MonoBehaviour
    {
        public List<PartTransform> PartTransforms = new List<PartTransform>();

        [System.Serializable]
        public class PartTransform
        {
            public int PartIndex;
            public Transform Transform;
        }

        public Transform GetTransformByPartID(int id)
        {
            foreach (PartTransform t in PartTransforms)
            {
                if (t.PartIndex == id)
                {
                    return t.Transform;
                }
            }

            return null;
        }

#if UNITY_EDITOR
        [CustomPropertyDrawer(typeof(PartTransform))]
        class GunPartsDrawer : PropertyDrawer
        {
            private GunExportConfig gunExportConfig = null;

            public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
            {
                return EditorGUIUtility.singleLineHeight * 2 + 6;
            }

            public override void OnGUI(Rect pos, SerializedProperty prop, GUIContent label)
            {
                if (gunExportConfig == null)
                {
                    string[] path = AssetDatabase.FindAssets("t:GunExportConfig");

                    if (path != null && path.Length > 0)
                    {
                        gunExportConfig = AssetDatabase.LoadAssetAtPath(AssetDatabase.GUIDToAssetPath(path[0]), typeof(GunExportConfig)) as GunExportConfig;
                    }
                }

                if (gunExportConfig != null)
                {
                    var labelAnimActionPos = new Rect(pos.x, pos.y, pos.width, 16);
                    var animActionPos = new Rect(pos.x + pos.width / 3, pos.y, width: 150, 16);
                    var labelTransformPos = new Rect(pos.x, pos.y + 16, pos.width, 16);
                    var transfomPos = new Rect(pos.x + pos.width / 3, pos.y + 16, width: 200, 16);

                    using (SerializedProperty gunParPos = prop.FindPropertyRelative("PartIndex"))
                    {
                        EditorGUI.LabelField(labelAnimActionPos, "Mesh Part");
                        gunParPos.intValue = EditorGUI.Popup(animActionPos, gunParPos.intValue, gunExportConfig.GunMeshExportConfig.GunAttachPosition.ToArray());
                    }

                    using (SerializedProperty gunTransformPos = prop.FindPropertyRelative("Transform"))
                    {
                        EditorGUI.LabelField(labelTransformPos, "Transfom");
                        gunTransformPos.objectReferenceValue = (Transform)EditorGUI.ObjectField(transfomPos, gunTransformPos.objectReferenceValue, typeof(Transform), true);

                    }
                }
            }
        }
#endif
    }
}