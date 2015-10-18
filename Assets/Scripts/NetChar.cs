using UnityEngine;
using System.Collections;
 
public class NetChar : Photon.MonoBehaviour
{
	Vector3 actualPosition = Vector3.zero;
	Quaternion actualRotation = Quaternion.identity;
	Animator anim;
	
	//For initialization.
	void Start () {
		anim = GetComponent<Animator>();
		if(anim == null) {
			Debug.LogError ("Animator is missing on player prefab.");
		}
	}
	
	//Called once every frame.
	void Update () {
		if (photonView.isMine) {
			//Do nothing, our player is already being controlled by our other scripts.
		} else {
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
			actualPosition = (Vector3)stream.ReceiveNext();
			actualRotation = (Quaternion)stream.ReceiveNext();
			anim.SetFloat("Walk", (float)stream.ReceiveNext());
			anim.SetFloat("Turn", (float)stream.ReceiveNext());
			anim.SetFloat("Run", (float)stream.ReceiveNext());
			anim.SetBool("Jump", (bool)stream.ReceiveNext());
        }
    }
}