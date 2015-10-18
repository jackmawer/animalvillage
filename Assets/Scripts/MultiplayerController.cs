using UnityEngine;
using System.Collections;
using UnityStandardAssets.Cameras;

public class MultiplayerController : MonoBehaviour {
	public string playerPrefab;
	[HideInInspector]
	public string version = "Build 0001";
	[HideInInspector]
	public string versionWarning;

	// Use this for initialization
	void Start()
	{
		PhotonNetwork.ConnectUsingSettings(version);//Stops people on wrong version from connecting to this version.
	}
	
	void OnGUI()
	{
		if (Debug.isDebugBuild) {
		    //GUILayout.Label(PhotonNetwork.connectionStateDetailed.ToString());
		    GUILayout.Label(getCurrentDebugLabel());
		}
	}
	
	public string getCurrentDebugLabel () 
	{
	    versionWarning = Debug.isDebugBuild
	        ? "[Development Build, Do not distribute!]"
	        : "[Testing Copy, Do not distribute!]";
        string currentDebugLabel = "Animal Village\nBy Jack Mawer\nVersion "+version+" "+versionWarning+"\n\n"+getDateTime ("")+"\nServer Status: "+PhotonNetwork.connectionStateDetailed.ToString();
		return currentDebugLabel;
	}

	void OnJoinedLobby ()
	{
		RoomOptions roomOptions = new RoomOptions() { isVisible = true, maxPlayers = 0 };
		PhotonNetwork.JoinOrCreateRoom("Default", roomOptions, TypedLobby.Default);
	}

	void OnPhotonJoinRoomFailed (object[] reasonForFailure)
	{
		//Example: void OnPhotonJoinRoomFailed(object[] codeAndMsg) { // codeAndMsg[0] is int ErrorCode. codeAndMsg[1] is string debug msg. } 
		Debug.Log ("Failed to join room with code " + reasonForFailure[0] + " message " + reasonForFailure[1] + ". Retrying.");
		//Annoyingly, there's no way to tell which room we were joining, which isn't a problem right now, because we're always using 
		//the 'Default' room, but will become a problem later when we let players use a custom room.
		OnJoinedLobby ();//Try again.
	}

	void OnJoinedRoom() 
	{
		SpawnPlayer ();//Don't delay, throw our guy (or gal) in.
	}
	private void SpawnPlayer()
	{
		Debug.Log ("SpawnPlayer");

		GameObject player = PhotonNetwork.Instantiate(playerPrefab, new Vector3(0, 0, 0), Quaternion.identity, 0);
		
		//CharacterController controller = player.GetComponent<CharacterController>();
		//controller.enabled = true;
		
		Character_Animations controller = player.GetComponent<Character_Animations>();
		controller.enabled = true;
		
		UnityStandardAssets.Cameras.AutoCam mainCamera = GameObject.FindWithTag("MainCameraRoot").GetComponent<AutoCam>();
		mainCamera.SetTarget(player.transform);

		//PlayerControl controller = MyPlayer.GetComponent<PlayerControl>();
		//controller.enabled = true;
		//ThirdPersonOrbitCam cam = Camera.main.GetComponent<ThirdPersonOrbitCam>();
		//cam.player = GameObject.transform;
		//Camera camera = MyPlayer.GetComponent<Camera>();
		//camera.enabled = true;

		//PhotonView myPhotonView;
		//myPhotonView = MyPlayer.GetComponent<PhotonView>();
		//if (myPhotonView.isMine) {
		//	RigidbodyFirstPersonController playerControl = MyPlayer.GetComponent<RigidbodyFirstPersonController> ();
		//	playerControl.enabled = true;
		//	GameObject playerCamera = MyPlayer.transform.Find("Camera").gameObject;
		//	playerCamera.active = true;
		//}
	}

	// Update is called once per frame
	void Update () {
	
	}

	public string getDateTime(string dateOrTime) 
	{
		string currentDateFormatted;
		string currentTimeFormatted;
		string dateOrTimeResponse;

		currentDateFormatted = System.DateTime.Now.ToString("dd/MM/yyyy");
		currentTimeFormatted = System.DateTime.Now.ToString("HH:mm:ss");
		if (dateOrTime == "time")
		{
			dateOrTimeResponse = currentTimeFormatted;
		} else if (dateOrTime == "date") 
		{
			dateOrTimeResponse = currentDateFormatted;
		} else
		{
			//Debug.LogWarning("getDateTime(string dateOrTime): Expected either 'date' or 'time' but got '"+dateOrTime+"', assuming you want both.");
			dateOrTimeResponse = currentDateFormatted+" "+currentTimeFormatted;
		}
		return dateOrTimeResponse;
	}
}
