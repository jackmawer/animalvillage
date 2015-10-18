using UnityEngine;
using System.Collections;

public class NetChar : Photon.MonoBehaviour
{
    private Vector3 actualPosition;
    private Quaternion actualRotation;
    private Animator anim;

    //For initialization.
    private void Start()
    {
        actualPosition = Vector3.zero;
        actualRotation = Quaternion.identity;
        anim = GetComponent<Animator>();
        if (anim == null)
        {
            Debug.LogError("Animator is missing on player prefab.");
        }
    }

    //Called once every frame.
    private void Update()
    {
        if (!photonView.isMine)
        {
            //This player isn't ours, so let's update it.
            transform.position = Vector3.Lerp(transform.position, actualPosition, 0.1f);
            transform.rotation = Quaternion.Lerp(transform.rotation, actualRotation, 0.1f);
        }
    }

    public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
    {
        if (stream.isWriting)
        {
            // We own this player: send the others our data
            stream.SendNext(transform.position);
            stream.SendNext(transform.rotation);
            stream.SendNext(anim.GetFloat("Walk"));
            stream.SendNext(anim.GetFloat("Turn"));
            stream.SendNext(anim.GetFloat("Run"));
            stream.SendNext(anim.GetBool("Jump"));
        }
        else
        {
            // Network player, receive data
            actualPosition = (Vector3) stream.ReceiveNext();
            actualRotation = (Quaternion) stream.ReceiveNext();
            anim.SetFloat("Walk", (float) stream.ReceiveNext());
            anim.SetFloat("Turn", (float) stream.ReceiveNext());
            anim.SetFloat("Run", (float) stream.ReceiveNext());
            anim.SetBool("Jump", (bool) stream.ReceiveNext());
        }
    }
}