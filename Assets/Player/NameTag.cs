using UnityEngine;
using System.Collections;

public class NameTag : MonoBehaviour {
	public Transform target;
	private string textToDisplay;
	
	public bool displayName = true;
	public bool displayTAG = false;
	
	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		nameDisplayer();
		tagDisplayer();
	}
	
	void LateUpdate (){
		//Make the text always face the camera
		transform.rotation = Camera.main.transform.rotation;
	}
	
	//displays the name of the parent
	void nameDisplayer(){
		if(displayName){
			displayTAG = false;
			textToDisplay = (string)this.transform.parent.name;
			//changes the text to the Name
			changeTextColor();
		}
	}
	
	//displays the TAG of the parent
	void tagDisplayer(){
		if(displayTAG){
			displayName = false;
			//changes the text to the TAG
			textToDisplay = (string)this.transform.parent.tag;
			changeTextColor();
		}
	}
	
	//Changes the color
	public void changeTextColor() {
		
		//Enemy = red
		if(this.transform.parent.tag == "Enemy"){
			GetComponent<Renderer>().material.color = Color.red;
		} else if (this.transform.parent.tag == "Player"){
			GetComponent<Renderer>().material.color = Color.green;
		} else {
			GetComponent<Renderer>().material.color = Color.yellow;
		}
		
		// Access the TextMesh component and change it for "textToDisplay" value
		TextMesh tm = GetComponent<TextMesh>();
		tm.text = textToDisplay;
	}
}
