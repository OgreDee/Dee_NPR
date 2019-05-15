using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotation : MonoBehaviour
{
    Transform _cacheTrans;
    Transform cacheTrans { get { return _cacheTrans = _cacheTrans ?? transform; } }


    // Update is called once per frame
    void Update()
    {
        cacheTrans.Rotate(Vector3.forward, 1f);
    }
}
