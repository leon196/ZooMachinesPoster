using UnityEngine;
using System.Collections;
using System.Net;
using System.Net.Sockets;

public class Printer : MonoBehaviour {

	TcpClient tcpClient = null;

	// Use this for initialization
	void Start () 
	{
		int port = 13000;
		tcpClient = new TcpClient("127.0.0.1", port);
	}

	void Update ()
	{
		if (Input.GetKeyDown (KeyCode.Space))
			StartCoroutine (CaptureScreenshot ());
	}

	public IEnumerator CaptureScreenshot ()
	{
		yield return null;

		string path = string.Format ("Album\\{0:yyyy-MM-dd_hh-mm-ss-tt}.png", System.DateTime.Now);

		Application.CaptureScreenshot (path, 2);

		yield return null;

		string mspaintArgs = string.Format ("/p {0}", path);

		// System.Diagnostics.Process.Start("mspaint", mspaintArgs);
	
		yield return null;

		string tcpMessage = string.Format ("{0};{1}", System.IO.Path.GetFullPath(path), "");
		byte[] data = System.Text.Encoding.ASCII.GetBytes (tcpMessage);
		NetworkStream stream = tcpClient.GetStream();
		stream.Write(data, 0, data.Length);
	}
}
