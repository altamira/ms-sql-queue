//===============================================================================
// Copyright © 2010 Microsoft Corporation.  All rights reserved.
// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY
// OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE.
//===============================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Diagnostics;
using System.Data.SqlClient;

namespace QueueProcessor
{
  class InboundMessageProcessor
  {
    public static void ProcessMessage(byte[] buffer)
    {
        // if the original encoding was ASCII
        //string body = Encoding.ASCII.GetString(buffer);

        // if the original encoding was UTF-8
        //string body = Encoding.UTF8.GetString(buffer);

        // if the original encoding was UTF-16
        string body = Encoding.Unicode.GetString(buffer);

        Trace.WriteLine("Recieved Message: " + body);

        return;
    }

    public static void SaveFailedMessage(byte[] message, SqlConnection con, Exception errorInfo)
    {
      Trace.WriteLine("InboundMessageProcessor Recieved Failed Message");
      return;
    }
  }
}
