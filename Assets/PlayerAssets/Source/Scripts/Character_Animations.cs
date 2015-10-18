using UnityEngine;
using System.Collections;

public class Character_Animations : MonoBehaviour {

internal Animator animator;
float v;
float h;
float run;

void  Start (){
	animator = GetComponent<Animator>();
}

void  Update (){
	v=Input.GetAxis("Vertical");
	h=Input.GetAxis("Horizontal");
	if (animator.GetFloat("Run")==0.2f){
		if (Input.GetKeyDown("space")){
			animator.SetBool("Jump",true);
		}
	}
	Sprinting();
	
}

void  FixedUpdate (){
	animator.SetFloat("Walk",v);
	animator.SetFloat("Run",run);
	animator.SetFloat("Turn",h);
}

void  Sprinting (){
	if (Input.GetKey(KeyCode.LeftShift)){
		run=0.2f;
	}
	else
	{
		run=0.0f;
	}
}
}