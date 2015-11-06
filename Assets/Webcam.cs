using UnityEngine;
using System.Collections;

public class Webcam : MonoBehaviour 
{
	WebCamTexture webcamTexture;

	void Start () 
	{
		foreach (WebCamDevice device in WebCamTexture.devices)
		{
			Debug.Log(device.name);
		}
		if (WebCamTexture.devices.Length > 0)
		{
			webcamTexture = new WebCamTexture();
			GetComponent<Renderer>().material.mainTexture = webcamTexture;
			webcamTexture.Play();
		}
	}
	
	void Update ()
	{	
	}
}
