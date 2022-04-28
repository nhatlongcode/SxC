// ***********************************************************************
// Assembly         : Assembly-CSharp-firstpass
// Author           : Haoppd (haoppd@vng.com.vn)
// Created          : 03-29-2019
// Last Modified By : Haoppd (haoppd@vng.com.vn)
// Last Modified On : 03-29-2019  1:58 PM
// ***********************************************************************
// <copyright file="CameraController.cs" company="VNG Corporation">
//     Copyright (c) 2019 VNG Corporation. All rights reserved.
// </copyright>
// <summary></summary>
// ***********************************************************************

namespace MadTools
{
    using UnityEngine;

    public class CameraController : MonoBehaviour
    {
        public float mouseSensitivity = 100.0f;
        public float clampAngle = 80.0f;

        private float rotY = 0.0f; // rotation around the up/y axis
        private float rotX = 0.0f; // rotation around the right/x axis

        void Start()
        {
            Vector3 rot = transform.localRotation.eulerAngles;
            rotY = rot.y;
            rotX = rot.x;
        }

        void Update()
        {
            if (Input.GetMouseButton(0))
            {
                float mouseX = Input.GetAxis("Mouse X");
                float mouseY = -Input.GetAxis("Mouse Y");

                rotY += mouseX * mouseSensitivity * Time.deltaTime;
                rotX += mouseY * mouseSensitivity * Time.deltaTime;

                rotX = Mathf.Clamp(rotX, -clampAngle, clampAngle);

                Quaternion localRotation = Quaternion.Euler(rotX, rotY, 0.0f);
                transform.rotation = localRotation;
            }           
        }
    }
}