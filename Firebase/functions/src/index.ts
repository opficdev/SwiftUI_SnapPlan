import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import axios from "axios";
import * as jwt from "jsonwebtoken";
import * as dotenv from "dotenv";

// .env 파일 로드
dotenv.config();

admin.initializeApp();

// 새로운 Cloud Function 추가
export const getAppleRefreshToken = onCall({
  cors: true,
  maxInstances: 10,
  region: "asia-northeast3",
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  try {
// 요청 데이터가 null인지 확인
    console.log("Request data:", request.data);
    
    if (!request.data) {
      throw new HttpsError(
        "invalid-argument",
        "Request data is missing"
      );
    }
    
    const { authorizationCode, userId } = request.data;
    
    if (!authorizationCode || !userId) {
      throw new HttpsError("invalid-argument", "Authorization code and userId are required");
    }

    // Apple 설정 불러오기
    const teamId = process.env.APPLE_TEAM_ID;
    const clientId = process.env.APPLE_CLIENT_ID;
    const keyId = process.env.APPLE_KEY_ID;
    const privateKey = (process.env.APPLE_PRIVATE_KEY || "").replace(/\\n/g, "\n");

    if (!teamId || !clientId || !keyId || !privateKey) {
      throw new HttpsError("internal", "Missing Apple configuration");
    }

    // JWT 생성
    const clientSecret = jwt.sign({}, privateKey, {
      algorithm: "ES256",
      expiresIn: "5m",
      audience: "https://appleid.apple.com",
      issuer: teamId,
      subject: clientId,
      keyid: keyId,
    });

    // Apple 서버에 토큰 요청 (authorization_code 사용)
    const response = await axios.post<{
      access_token: string,
      refresh_token: string,
      id_token: string,
      token_type: string,
      expires_in: number
    }>(
      "https://appleid.apple.com/auth/token",
      new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        code: authorizationCode,
        grant_type: "authorization_code",
      }).toString(),
      {
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      }
    );

    // 리프레시 토큰을 Firestore에 저장 - 클라이언트 구조에 맞게 수정
    if (response.data && response.data.refresh_token) {
      // 클라이언트 구조에 맞게 collection(userId).document("info")로 변경
      await admin.firestore().collection(userId).doc("info").set({
        appleRefreshToken: response.data.refresh_token
      }, { merge: true }); // merge: true로 기존 필드 유지
      
      return { success: true };
    } else {
      throw new HttpsError("internal", "Failed to get refresh token from Apple");
    }
  } catch (error) {
    console.error("Error getting Apple refresh token:", error);
    throw new HttpsError("internal", "Failed to process Apple sign in");
  }
});

export const refreshAppleAccessToken = onCall({
  cors: true,
  maxInstances: 10,
  region: "asia-northeast3",
}, async (request) => {
  // 인증 확인
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  try {
    const userId = request.auth.uid;
    console.log("Auth user ID:", userId);
    
    // 클라이언트 경로에서만 시도
    console.log(`Fetching from collection(${userId})/doc(info)`);
    const userDoc = await admin.firestore().collection(userId).doc("info").get();
    
    if (!userDoc.exists) {
      console.error(`User document not found for ID: ${userId}`);
      throw new HttpsError("not-found", `User document not found at collection('${userId}')/doc('info')`);
    }
    
    const userData = userDoc.data();
    const refreshToken = userData?.appleRefreshToken;
    
    if (!refreshToken) {
      console.error("User document exists but has no appleRefreshToken field:", userData);
      throw new HttpsError("not-found", "Apple refresh token not found for this user");
    }
    
    console.log("Successfully retrieved refresh token from Firestore");
    
    // Apple configuration
    const teamId = process.env.APPLE_TEAM_ID;
    const clientId = process.env.APPLE_CLIENT_ID;
    const keyId = process.env.APPLE_KEY_ID;
    const privateKey = (process.env.APPLE_PRIVATE_KEY || "")
      .replace(/\\n/g, "\n");

    if (!teamId || !clientId || !keyId || !privateKey) {
      throw new HttpsError(
        "internal",
        "Missing Apple configuration environment variables."
      );
    }

    // Create client_secret JWT
    const clientSecret = jwt.sign({}, privateKey, {
      algorithm: "ES256",
      expiresIn: "5m",
      audience: "https://appleid.apple.com",
      issuer: teamId,
      subject: clientId,
      keyid: keyId,
    });

    // Request new access token from Apple
    const response = await axios.post<{access_token: string}>(
      "https://appleid.apple.com/auth/token",
      new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        grant_type: "refresh_token",
        refresh_token: refreshToken,
      }).toString(),
      {
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      }
    );

    // Return the new access token
    if (response.data && response.data.access_token) {
      return {token: response.data.access_token}; // v2에서는 객체로 반환
    } else {
      throw new HttpsError(
        "internal",
        "Failed to retrieve access token from Apple response."
      );
    }
  } catch (error: unknown) {
    console.error("Error refreshing Apple token:", error);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    if ((axios as any).isAxiosError(error)) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      console.error("Axios error details:", (error as any).response?.data);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      throw new HttpsError(
        "internal",
        `Token refresh failed: ${
          (error as any).response?.data?.error ||
          (error as Error).message
        }`
      );
    } else if (error instanceof Error) {
      throw new HttpsError(
        "internal",
        `Token refresh error: ${error.message}`
      );
    } else {
      throw new HttpsError(
        "internal",
        "An unknown error occurred during token refresh."
      );
    }
  }
});

export const revokeAppleAccessToken = onCall({
  cors: true,
  maxInstances: 10,
  region: "asia-northeast3",
}, async (request) => {
  // 인증 확인
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required");
  }

  try {
    const { token } = request.data;
    
    if (!token) {
      throw new HttpsError("invalid-argument", "Token is required");
    }

    // Apple 설정 불러오기
    const teamId = process.env.APPLE_TEAM_ID;
    const clientId = process.env.APPLE_CLIENT_ID;
    const keyId = process.env.APPLE_KEY_ID;
    const privateKey = (process.env.APPLE_PRIVATE_KEY || "").replace(/\\n/g, "\n");

    if (!teamId || !clientId || !keyId || !privateKey) {
      throw new HttpsError("internal", "Missing Apple configuration");
    }

    // JWT 생성
    const clientSecret = jwt.sign({}, privateKey, {
      algorithm: "ES256",
      expiresIn: "5m",
      audience: "https://appleid.apple.com",
      issuer: teamId,
      subject: clientId,
      keyid: keyId,
    });

    // Apple 서버에 토큰 취소 요청
    await axios.post(
      "https://appleid.apple.com/auth/revoke",
      new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        token: token,
        token_type_hint: "access_token" // access_token 또는 refresh_token 지정 가능
      }).toString(),
      {
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      }
    );

    return { success: true };
    
  } catch (error: unknown) {
    console.error("Error revoking Apple token:", error);
    
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    if ((axios as any).isAxiosError(error)) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      console.error("Axios error details:", (error as any).response?.data);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      throw new HttpsError(
        "internal",
        `Token revocation failed: ${
          (error as any).response?.data?.error ||
          (error as Error).message
        }`
      );
    } else if (error instanceof Error) {
      throw new HttpsError(
        "internal",
        `Token revocation error: ${error.message}`
      );
    } else {
      throw new HttpsError(
        "internal",
        "An unknown error occurred during token revocation."
      );
    }
  }
});

export const deleteUserSchedule = onCall({
  cors: true,
  maxInstances: 10,
  region: "asia-northeast3",
}, async (request) => {
  // 인증 확인
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "인증이 필요합니다");
  }
  
  // 요청 데이터 확인
  if (!request.data || !request.data.scheduleId) {
    throw new HttpsError("invalid-argument", "일정 ID가 필요합니다");
  }
  
  const userId = request.auth.uid;
  const { scheduleId } = request.data;
  
  try {
    // 1. Firestore에서 해당 일정 삭제
    await admin.firestore()
      .collection(userId)
      .doc("schedules")
      .collection("data")
      .doc(scheduleId)
      .delete();
    
    console.log(`Deleted schedule document: ${userId}/schedules/data/${scheduleId}`);
    
    // 2. Storage에서 관련 파일 삭제
    try {
      // 사진 파일 삭제
      await deleteDirectory(`photos/${userId}/${scheduleId}`);
      console.log(`Deleted photos for schedule: photos/${userId}/${scheduleId}`);
      
      // 음성 메모 파일 삭제
      await deleteDirectory(`voiceMemos/${userId}/${scheduleId}`);
      console.log(`Deleted voice memos for schedule: voiceMemos/${userId}/${scheduleId}`);
    } catch (storageError) {
      // 스토리지 파일이 없을 수도 있으므로 오류 기록만 하고 계속 진행
      console.warn(`Storage deletion warning: ${storageError instanceof Error ? storageError.message : 'Unknown error'}`);
    }
    
    return { success: true };
  } catch (error: unknown) {
    console.error("일정 삭제 중 오류 발생:", error);
    if (error instanceof Error) {
      throw new HttpsError(
        "internal", 
        `일정 삭제 중 오류 발생: ${error.message}`
      );
    } else {
      throw new HttpsError(
        "internal", 
        "일정 삭제 중 알 수 없는 오류가 발생했습니다."
      );
    }
  }
});

export const deleteUserAllStorage = onCall({
  cors: true,
  maxInstances: 10,
  region: "asia-northeast3",
}, async (request) => {
  // 인증 확인
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "인증이 필요합니다");
  }
  
  const userId = request.auth.uid;
  
  // Admin 권한으로 삭제 실행
  try {
    await deleteDirectory(`photos/${userId}`);
    await deleteDirectory(`voiceMemos/${userId}`);
    return { success: true };
  } catch (error: unknown) {
    console.error("Storage deletion error:", error);
    if (error instanceof Error) {
      throw new HttpsError(
        "internal", 
        `스토리지 삭제 중 오류 발생: ${error.message}`
      );
    } else {
      throw new HttpsError(
        "internal", 
        "스토리지 삭제 중 알 수 없는 오류가 발생했습니다."
      );
    }
  }
});

// 디렉토리 삭제 헬퍼 함수
async function deleteDirectory(path: string): Promise<boolean> {
  const bucket = admin.storage().bucket();
  
  try {
    // 디렉토리 내 모든 파일 목록 가져오기
    const [files] = await bucket.getFiles({ prefix: path });
    
    // 병렬로 모든 파일 삭제
    const deletePromises = files.map(file => file.delete());
    await Promise.all(deletePromises);
    
    return true;
  } catch (error) {
    console.error(`Error deleting directory ${path}:`, error);
    throw error;
  }
}

export const deleteUserAllSchedules = onCall({
  cors: true,
  maxInstances: 10,
  region: "asia-northeast3",
}, async (request) => {
  // 인증 확인
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "인증이 필요합니다");
  }
  
  const userId = request.auth.uid;
  
  try {
    // 스케줄 데이터 컬렉션 경로
    const schedulesCollectionRef = admin.firestore()
      .collection(userId)
      .doc("schedules")
      .collection("data");
    
    // 모든 스케줄 문서 가져오기
    const scheduleDocs = await schedulesCollectionRef.get();
    
    // 문서가 없는 경우
    if (scheduleDocs.empty) {
      console.log(`No schedule documents found for user ${userId}`);
      return { success: true, count: 0 };
    }
    
    const documents = scheduleDocs.docs;
    let totalCount = 0;
    const batchSize = 500; // Firestore 배치 최대 크기
    
    // 여러 배치로 나누어 처리
    for (let i = 0; i < documents.length; i += batchSize) {
      // 현재 배치 범위 계산
      const batch = admin.firestore().batch();
      const currentBatchDocs = documents.slice(i, Math.min(i + batchSize, documents.length));
      
      // 현재 배치에 삭제 작업 추가
      currentBatchDocs.forEach(doc => {
        batch.delete(doc.ref);
        totalCount++;
      });
      
      // 현재 배치 실행
      await batch.commit();
      console.log(`Batch ${Math.floor(i/batchSize) + 1} completed: deleted ${currentBatchDocs.length} documents`);
    }
    
    console.log(`Successfully deleted all ${totalCount} schedule documents for user ${userId}`);
    return { success: true, count: totalCount };
    
  } catch (error: unknown) {
    console.error("Error deleting schedule documents:", error);
    if (error instanceof Error) {
      throw new HttpsError(
        "internal", 
        `스케줄 데이터 삭제 중 오류 발생: ${error.message}`
      );
    } else {
      throw new HttpsError(
        "internal", 
        "스케줄 데이터 삭제 중 알 수 없는 오류가 발생했습니다."
      );
    }
  }
});
