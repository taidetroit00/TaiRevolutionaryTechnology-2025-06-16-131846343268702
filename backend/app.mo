import Bool "mo:base/Bool";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import HashMap "mo:map/Map";
import { phash; thash } "mo:map/Map";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Option "mo:base/Option";

persistent actor Filevault {

  // Define a data type for a file's chunks.
  type FileChunk = {
    chunk : Blob;
    index : Nat;
  };

  // Define a data type for a file's data.
  type File = {
    name : Text;
    chunks : [FileChunk];
    totalSize : Nat;
    fileType : Text;
  };

  // Define a data type for storing files associated with a user principal.
  type UserFiles = HashMap.Map<Text, File>;

  // HashMap to store the user data
  private var files = HashMap.new<Principal, UserFiles>();

  // Return files associated with a user's principal.
  private func getUserFiles(user : Principal) : UserFiles {
    switch (HashMap.get(files, phash, user)) {
      case null {
        let newFileMap = HashMap.new<Text, File>();
        let _ = HashMap.put(files, phash, user, newFileMap);
        newFileMap;
      };
      case (?existingFiles) existingFiles;
    };
  };

  // Check if a file name already exists for the user.
  public shared (msg) func checkFileExists(name : Text) : async Bool {
    Option.isSome(HashMap.get(getUserFiles(msg.caller), thash, name));
  };

  // Upload a file in chunks.
  public shared (msg) func uploadFileChunk(name : Text, chunk : Blob, index : Nat, fileType : Text) : async () {
    let userFiles = getUserFiles(msg.caller);
    let fileChunk = { chunk = chunk; index = index };

    switch (HashMap.get(userFiles, thash, name)) {
      case null {
        let _ = HashMap.put(userFiles, thash, name, { name = name; chunks = [fileChunk]; totalSize = chunk.size(); fileType = fileType });
      };
      case (?existingFile) {
        let updatedChunks = Array.append(existingFile.chunks, [fileChunk]);
        let _ = HashMap.put(
          userFiles,
          thash,
          name,
          {
            name = name;
            chunks = updatedChunks;
            totalSize = existingFile.totalSize + chunk.size();
            fileType = fileType;
          }
        );
      };
    };
  };

  // Return list of files for a user.
  public shared (msg) func getFiles() : async [{ name : Text; size : Nat; fileType : Text }] {
    Iter.toArray(
      Iter.map(
        HashMap.vals(getUserFiles(msg.caller)),
        func(file : File) : { name : Text; size : Nat; fileType : Text } {
          {
            name = file.name;
            size = file.totalSize;
            fileType = file.fileType;
          };
        }
      )
    );
  };

  // Return total chunks for a file
  public shared (msg) func getTotalChunks(name : Text) : async Nat {
    switch (HashMap.get(getUserFiles(msg.caller), thash, name)) {
      case null 0;
      case (?file) file.chunks.size();
    };
  };

  // Return specific chunk for a file.
  public shared (msg) func getFileChunk(name : Text, index : Nat) : async ?Blob {
    switch (HashMap.get(getUserFiles(msg.caller), thash, name)) {
      case null null;
      case (?file) {
        switch (Array.find(file.chunks, func(chunk : FileChunk) : Bool { chunk.index == index })) {
          case null null;
          case (?foundChunk) ?foundChunk.chunk;
        };
      };
    };
  };

  // Get file's type.
  public shared (msg) func getFileType(name : Text) : async ?Text {
    switch (HashMap.get(getUserFiles(msg.caller), thash, name)) {
      case null null;
      case (?file) ?file.fileType;
    };
  };

  // Delete a file.
  public shared (msg) func deleteFile(name : Text) : async Bool {
    Option.isSome(HashMap.remove(getUserFiles(msg.caller), thash, name));
  };
};
uajwy-bzusi-36jtj-ajvmc-nep3q-b7zmb-wbdua-smdjo-j77n2-p7ciw-tae
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   APPENDIX: How to apply the Apache License to your work.

      To apply the Apache License to your work, attach the following
      boilerplate notice, with the fields enclosed by brackets "[]"
      replaced with your own identifying information. (Don't include
      the brackets!)  The text should be enclosed in the appropriate
      comment syntax for the file format. We also recommend that a
      file or class name and description of purpose be included on the
      same "printed page" as the copyright notice for easier
      identification within third-party archives.

   Copyright 2022 DFINITY Foundation

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   ldotnet new webapp -o MyWebAppimitations under the License.
npm.pkg.github.com/:_authToken=TOKENnpm.pkg.github.com/:_authToken=TOKEN
{
  "[motoko]": {
    "editor.defaultFormatter": "dfinity-foundation.vscode-motoko",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
  }uajwy-bzusi-36jtj-ajvmc-nep3q-b7zmb-wbdua-smdjo-j77n2-p7ciw-tae
}
github/workflows
motoko.canister
mops add fuzz
"mo:fuzz";
Time.now()
let seed = 123456789;
let fuzz = Fuzz.fromSeed(seed);let seed = 123456789; let fuzz = Fuzz.fromSeed(seed);
type Generator = { 	next() : Nat; } let fuzz = Fuzz.create(generator);
let blob = await Random.blob(); let fuzz = Fuzz.fromBlob(blob);
type Generator = {
	next() : Nat;
}
let fuzz = Fuzz.create(generator);type Generator = { 	next() : Nat; } let fuzz = Fuzz.create(generator);
let randNat = fuzz.nat.random(); let randNat32 = fuzz.nat32.random(); let randInt16 = fuzz.int16.random(); let randFloat = fuzz.float.random();
let randNat = fuzz.nat.randomRange(2**128, 2**256);
let randNat32 = fuzz.nat32.randomRange(1_100, 10_000);
let randInt16 = fuzz.int16.randomRange(8, 99);
let randFloat = fuzz.float.randomRange(0.5, 10.88);let randNat = fuzz.nat.randomRange(2**128, 2**256); let randNat32 = fuzz.nat32.randomRange(1_100, 10_000); let randInt16 = fuzz.int16.randomRange(8, 99); let randFloat = fuzz.float.randomRange(0.5, 10.88);
let nat16Min = fuzz.nat.min(); let int32Min = fuzz.int32.min(); let int32Max = fuzz.int32.max();
let arrayNat8 = fuzz.array.randomArray(1000, fuzz.nat8.random);
type MyType = { 	x : Nat; 	b : Bool; }; let randArray = fuzz.array.randomArray<MyType>(500, func() { 	return { 		x = fuzz.nat.random(); 		b = fuzz.bool.random(); 	}; });
let myArr = [1,2,4,4,4,55,1,2];

let item = fuzz.array.randomValue(myArr);
// or
let (index, item) = fuzz.array.randomEntry(myArr);let myArr = [1,2,4,4,4,55,1,2]; let item = fuzz.array.randomValue(myArr); // or let (index, item) = fuzz.array.randomEntry(myArr);
let randBlob = fuzz.blob.randomBlob(1024);
let randBool = fuzz.bool.random();
let myVal = { x = 3 }; let randOpt = fuzz.option.optOrNot(myVal); // => either ?{ x = 3 } or null
let char = fuzz.char.randomAlphabetic();
let char = fuzz.char.randomAlphanumeric();
[a-zA-Z0-9!"#$%&'()*+,-./,':;<=>?[\]^_`{|}~])")
let char = fuzz.char.randomAscii();
let char = fuzz.char.randomUnicode(['a', 'b', '%', '.', ',', '0', '1']);
let text = fuzz.text.randomText(17); // => "Lorem ipsum dolor" let text = fuzz.text.randomText(8); // => "Lorem ip"
let text = fuzz.text.randomAlphabetic(5); // => "aadkd" let text = fuzz.text.randomAlphabetic(5); // => "kfiky"
[a-zA-Z0-9])
= fuzz.text.randomAlphanumeric(3); // => "po8" let text = fuzz.text.randomAlphanumeric(3); // => "68r"
[a-zA-Z0-9!"#$ %&'()*+,-./,':;<=>?[\]^_`{|}~])();"]"
let text = fuzz.text.randomAscii(2); // => "t@" let text = fuzz.text.randomAscii(2); // => "pl"
let principal = fuzz.principal.randomPrincipal(10); Principal.toText(principal); // => "4u4hq-3aaae-bagaz-jaeba-kaq"
type Account = { 	owner: Principal; 	subaccount: ?Blob; }; let account: Account = fuzz.icrc1.randomAccount(); // or just let account2 = fuzz.icrc1.randomAccount();
let subaccount: Blob = fuzz.icrc1.randomSubaccount();"]
//npm.pkg.github.com/:_authToken=TOKEN
$ npm login --scope=@NAMESPACE --auth-type=legacy --registry=https://npm.pkg.github.com > Username: USERNAME > Password: TOKEN
@NAMESPACE:registry=https://npm.pkg.github.com
npm publish
"publishConfig": { "registry": "https://npm.pkg.github.com" },
@NAMESPACE:registry=https://npm.pkg.github.com
package dependency.

{ "name": "@my-org/server", "version": "1.0.0", "description": "Server app that uses the ORGANIZATION_NAME/PACKAGE_NAME package", "main": "index.js", "author": "", "license": "MIT", "dependencies": { "ORGANIZATION_NAME/PACKAGE_NAME": "1.0.0" } }
npm install
@NAMESPACE:registry=https://npm.pkg.github.com @NAMESPACE:registry=https://npm.pkg.github.com

sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"





